import Foundation
import SwiftData

@MainActor
class DashboardViewModel: ObservableObject {
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol

    @Published var badges: [Badge] = []
    @Published var co2Emitted: Float64 = 0.0
    @Published var treesPlanted: Int = 0
    @Published var co2Compensated: Float64 = 0.0
    @Published var totalDistance: Float64 = 0.0
    @Published var totalDuration: Int = 0
    @Published var mostChosenVehicle: String = ""
    @Published var visitedContinents: Int = 0
    
    var travelDetailsList: [TravelDetails] = []
    init(modelContext: ModelContext, serverService: ServerServiceProtocol) {
        self.modelContext = modelContext
        self.serverService = serverService
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
                    if let currentValue = vehicles[travel.findVehicle(outwardDirection: travel.isOneway())] {
                        vehicles[travel.findVehicle(outwardDirection: travel.isOneway())] = currentValue + 1
                    }
                }
            }
            visitedContinents = continents.count
            treesPlanted = Int(co2Compensated/75)
            mostChosenVehicle = vehicles.max(by: { $0.value < $1.value })?.key ?? ""
                
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
    private func resetParameters() {
        co2Emitted = 0.0
        treesPlanted = 0
        co2Compensated = 0.0
        totalDistance = 0.0
        totalDuration = 0
        mostChosenVehicle = ""
        visitedContinents = 0
    }
}
