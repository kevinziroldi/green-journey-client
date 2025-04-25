import Foundation
import SwiftData

@MainActor
class DashboardViewModel: ObservableObject {
    private let uuid: UUID = UUID()
    private var modelContext: ModelContext
    private let serverService: ServerServiceProtocol
    
    @Published var co2Emitted: Float64 = 0.0
    @Published var treesPlanted: Int = 0
    @Published var co2Compensated: Float64 = 0.0
    @Published var totalDistance: Float64 = 0.0
    @Published var mostChosenVehicle: String = "car"
    @Published var visitedContinents: [String] = []
    @Published var totalDurationString: String = ""
    private var distancesRaw: [Int: Int] = [:]
    @Published var distances: [String: Int] = [:]
    private var tripsMadeRaw: [Int: Int] = [:]
    @Published var tripsMade: [String: Int] = [:]
    @Published var countriesPerContinent: [String: Float64] = ["Europe": 0, "Asia": 0, "Africa": 0, "North America": 0, "South America": 0, "Oceania": 0]
    @Published var co2EmittedPerYear: [Int: Double] = [:]
    @Published var co2CompensatedPerYearKg: [Int: Double] = [:]
    @Published var co2CompensatedPerYearNumTrees: [String: Int] = [:]
    @Published var co2PerTransport: [String: Float64] = ["car": 0, "plane": 0, "bus": 0, "train": 0]
    @Published var distancePerTransport: [String: Float64] = ["car": 0, "bike": 0, "plane": 0, "bus": 0, "train": 0]
    @Published var travelsPerTransport: [String: Int] = ["car": 0, "bike": 0, "plane": 0, "bus": 0, "train": 0]
    @Published var visitedCountries: Int = 0
    @Published var totalTripsMade: Int = 0
    @Published var mostVisitedCountries: [String: Float64] = [:]
    
    var totalDuration: Int = 0
    var travelDetailsList: [TravelDetails] = []
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol) {
        self.modelContext = modelContext
        self.serverService = serverService
        self.distancesRaw = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
        self.tripsMadeRaw = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
        self.co2EmittedPerYear = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
        self.co2CompensatedPerYearKg = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
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
            var countries: [String] = []
            var vehicles = ["car": 0, "bicycle": 0, "airplane": 0, "bus": 0, "tram": 0]
            var visitedCountriesCount: [String: Int] = [:]
            
            for travel in travelDetailsList {
                if travel.travel.confirmed {
                    totalTripsMade += 1
                    co2Emitted += travel.computeCo2Emitted()
                    co2Compensated += travel.travel.CO2Compensated
                    totalDistance += travel.computeTotalDistance()
                    for segment in travel.segments {
                        totalDuration += segment.duration/1000000000
                        if segment.vehicle != Vehicle.walk {
                            if let currentCo2Emitted = co2PerTransport[segment.vehicle.rawValue] {
                                co2PerTransport[segment.vehicle.rawValue] = currentCo2Emitted + segment.co2Emitted
                            }
                            if let currentDistance = distancePerTransport[segment.vehicle.rawValue] {
                                distancePerTransport[segment.vehicle.rawValue] = currentDistance + segment.distance
                            }
                        }
                    }
                    let continent = getDestContinent(country: travel.getDepartureSegment()?.destinationCountry ?? "")
                    if (!visitedContinents.contains(continent)) {
                        visitedContinents.append(continent)
                    }
                    let country = travel.getDestinationSegment()?.destinationCountry ?? ""
                    if (!countries.contains(country)) {
                        countries.append(country)
                        if let currentCountries = countriesPerContinent[continent] {
                            countriesPerContinent[continent] = currentCountries + 1
                        }
                    }
                    if let currentNumVehicle = vehicles[travel.findVehicle(outwardDirection: travel.isOneway())] {
                        vehicles[travel.findVehicle(outwardDirection: travel.isOneway())] = currentNumVehicle + 1
                    }
                    if let currentNumTrips = tripsMadeRaw[travel.getYear()] {
                        tripsMadeRaw[travel.getYear()] = currentNumTrips + 1
                    }
                    if let currentDistance = distancesRaw[travel.getYear()] {
                        distancesRaw[travel.getYear()] = currentDistance + Int(travel.computeTotalDistance())
                    }
                    if let currentCo2Emitted = co2EmittedPerYear[travel.getYear()] {
                        co2EmittedPerYear[travel.getYear()] = currentCo2Emitted + travel.computeCo2Emitted()
                    }
                    if let currentCo2Compensated = co2CompensatedPerYearKg[travel.getYear()] {
                        co2CompensatedPerYearKg[travel.getYear()] = currentCo2Compensated + travel.travel.CO2Compensated
                    }
                    
                    if let currentCount = visitedCountriesCount[country] {
                        // if in visitedCountriesCount, add 1
                        visitedCountriesCount[country] = currentCount + 1
                    } else {
                        // else add to visitedCountriesCount
                        visitedCountriesCount[country] = 1
                    }
                    
                }
            }
            treesPlanted = Int(co2Compensated/75)
            mostChosenVehicle = vehicles.max(by: { $0.value < $1.value })?.key ?? ""
            visitedCountries = countries.count
            totalDurationString = convertTotalDuration()
            travelsPerTransport["car"] = vehicles["car"]
            travelsPerTransport["bike"] = vehicles["bicycle"]
            travelsPerTransport["train"] = vehicles["tram"]
            travelsPerTransport["plane"] = vehicles["airplane"]
            travelsPerTransport["bus"] = vehicles["bus"]
            
            self.mostVisitedCountries = Dictionary (
                uniqueKeysWithValues: visitedCountriesCount.sorted { $0.value > $1.value }
                    .prefix(5)
                    .map { ($0.key, Float64($0.value)) }
            )
            
            self.co2CompensatedPerYearNumTrees = co2CompensatedPerYearKg.reduce(into: [String: Int]()) { result, pair in
                result[String(pair.key)] = Int(pair.value / 75)
            }
            
            self.distances = distancesRaw.reduce(into: [String: Int]()) {
                result, pair in
                result[String(pair.key)] = pair.value
            }
            
            self.tripsMade = tripsMadeRaw.reduce(into: [String: Int]()) {
                result, pair in
                result[String(pair.key)] = pair.value
            }
        }
        catch {
            print("Error fetching user travels")
        }
    }
    
    func computeProgress() -> Double {
        if co2Emitted == 0 {
            return 0
        }
        if co2Compensated/co2Emitted > 1 {
            return 1
        }
        // else
        return co2Compensated / co2Emitted
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
            print("Error while finding continent")
            return ""
        }
    }
    
    private func convertTotalDuration() -> String {
        return DurationAsString.convertTotalDurationToString(totalDuration: totalDuration)
    }
    
    private func resetParameters() {
        co2Emitted = 0.0
        treesPlanted = 0
        co2Compensated = 0.0
        totalDistance = 0.0
        totalDuration = 0
        mostChosenVehicle = "car"
        visitedContinents = []
        visitedCountries = 0
        totalTripsMade = 0
        distancesRaw = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
        tripsMadeRaw = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
        co2EmittedPerYear = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
        co2CompensatedPerYearKg = [getCurrentYear()-3: 0, getCurrentYear()-2: 0, getCurrentYear()-1: 0, getCurrentYear(): 0]
        co2PerTransport = ["car": 0, "plane": 0, "bus": 0, "train": 0]
        distancePerTransport = ["car": 0, "bike": 0, "plane": 0, "bus": 0, "train": 0]
        travelsPerTransport = ["car": 0, "bike": 0, "plane": 0, "bus": 0, "train": 0]
        countriesPerContinent = ["Europe": 0, "Asia": 0, "Africa": 0, "North America": 0, "South America": 0, "Oceania": 0]
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
extension DashboardViewModel: Hashable {
    nonisolated static func == (lhs: DashboardViewModel, rhs: DashboardViewModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
