import Foundation
import SwiftData

@MainActor
class DashboardViewModel: ObservableObject {
    private var modelContext: ModelContext
    private let serverService: ServerServiceProtocol

    @Published var badges: [Badge] = []
    @Published var shortDistanceScore: Float64 = 0.0
    @Published var longDistanceScore: Float64 = 0.0
    @Published var co2Emitted: Float64 = 0.0
    @Published var treesPlanted: Int = 0
    @Published var co2Compensated: Float64 = 0.0
    @Published var totalDistance: Float64 = 0.0
    @Published var mostChosenVehicle: String = "car"
    @Published var visitedContinents: Int = 0
    @Published var totalDurationString: String = ""
    @Published var distances: [Int: Int] = [:]
    @Published var tripsMade: [Int: Int] = [:]
    

    @Published var totalTripsMade: Int = 0
    var totalDuration: Int = 0
    var travelDetailsList: [TravelDetails] = []
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol) {
        self.modelContext = modelContext
        self.serverService = serverService
        self.distances = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
        self.tripsMade = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
    }
    
    func getUserBadges() {
        do {
            let users = try modelContext.fetch(FetchDescriptor<User>())
            if let user = users.first {
                self.badges = user.badges
            } else {
                self.badges = []
            }
        }catch {
            print("Error fetching user data")
        }
    }
    
    func getUserFromServer() async{
        do {
            let user = try await serverService.getUser()
            badges = user.badges
            shortDistanceScore = user.scoreShortDistance
            longDistanceScore = user.scoreLongDistance
            saveUserToSwiftData(serverUser: user)
        }
        catch {
            print("Error retrieving user from server")
        }
    }
    
    private func saveUserToSwiftData(serverUser: User?) {
        if let user = serverUser {
            // check no user logged
            do {
                let users = try modelContext.fetch(FetchDescriptor<User>())
                if users.count > 0 {
                    for user in users {
                        modelContext.delete(user)
                    }
                    try modelContext.save()
                    print("Some user is already logged and is being removed, new user loaded to SwiftData")
                }
            } catch {
                print("Error while checking number of users: \(error)")
                return
            }
            
            // add user to context
            modelContext.insert(user)
            
            // save user in SwiftData
            do {
                try modelContext.save()
                print("Saved user (firebaseUID " + user.firebaseUID + ") in SwiftData")
            } catch {
                print("Error while saving user to SwiftData: \(error)")
                return
            }
        }
    }
    
    func getUserTravels() {
        do {
            resetParameters()
            let travels = try modelContext.fetch(FetchDescriptor<Travel>())
            let segments = try modelContext.fetch(FetchDescriptor<Segment>())
            
            let segmentsByTravelID = Dictionary(grouping: segments, by: { $0.travelID })
            travelDetailsList = travels.compactMap { travel in
                if let travelID = travel.travelID {
                    if let travelSegments = segmentsByTravelID[travelID] {
                        return TravelDetails(travel: travel, segments: travelSegments)
                    } else {
                        return TravelDetails(travel: travel, segments: [])
                    }
                }
                return nil
            }
           
            var continents: [String] = []
            var vehicles = ["car": 0, "bicycle": 0, "airplane": 0, "bus": 0, "tram": 0]
            for travel in travelDetailsList {
                if travel.travel.confirmed {
                    totalTripsMade += 1
                    co2Emitted += travel.computeCo2Emitted()
                    co2Compensated += travel.travel.CO2Compensated
                    totalDistance += travel.computeTotalDistance()
                    for segment in travel.segments {
                        totalDuration += segment.duration/1000000000
                    }
                    let continent = getDestContinent(country: travel.getDepartureSegment()?.destinationCountry ?? "")
                    if (!continents.contains(continent)) {
                        continents.append(continent)
                    }
                    if let currentNumVehicle = vehicles[travel.findVehicle(outwardDirection: travel.isOneway())] {
                        vehicles[travel.findVehicle(outwardDirection: travel.isOneway())] = currentNumVehicle + 1
                    }
                    if let currentNumTrips = tripsMade[travel.getYear()] {
                        tripsMade[travel.getYear()] = currentNumTrips + 1
                    }
                    if let currentDistance = distances[travel.getYear()] {
                        distances[travel.getYear()] = currentDistance + Int(travel.computeTotalDistance())
                    }
                }
            }
            visitedContinents = continents.count
            treesPlanted = Int(co2Compensated/75)
            mostChosenVehicle = vehicles.max(by: { $0.value < $1.value })?.key ?? ""
            totalDurationString = convertTotalDuration()
        }
        catch {
            print("Error fetching user travels")
        }
    }
    
    private func getDestContinent(country: String) -> String {
        var fetchDescriptor = FetchDescriptor<CityCompleterDataset>(
            predicate: #Predicate<CityCompleterDataset> {
                $0.countryName == country }
        )
        fetchDescriptor.fetchLimit = 1
        
        do {
            let continent = try modelContext.fetch(fetchDescriptor).first?.continent ?? "Europe"
            return continent
        } catch {
            print("Error while finding continent: \(error.localizedDescription)")
            return ""
        }
    }
    
    private func convertTotalDuration() -> String {
        return UtilitiesFunctions.convertTotalDurationToString(totalDuration: totalDuration)
    }
    
    private func resetParameters() {
        co2Emitted = 0.0
        treesPlanted = 0
        co2Compensated = 0.0
        totalDistance = 0.0
        totalDuration = 0
        mostChosenVehicle = "car"
        visitedContinents = 0
        totalTripsMade = 0
        distances = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
        tripsMade = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
    }
    
    func keysToString(keys: [Int]) -> [String] {
        var stringKeys: [String] = []
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        for k in keys {
            stringKeys.append(formatter.string(from: NSNumber(value: k)) ?? "")
        }
        return stringKeys
    }
    
    private func getCurrentYear() -> Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(.year, from: Date())
    }
}
