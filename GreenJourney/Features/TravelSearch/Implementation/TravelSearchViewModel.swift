import Combine
import CoreML
import Foundation
import MapKit
import SwiftData

@MainActor
class TravelSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    let uuid: UUID = UUID()
    
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    private var logic: TravelSearchLogic = TravelSearchLogic()
    
    @Published var departure: CityCompleterDataset = CityCompleterDataset()
    @Published var arrival: CityCompleterDataset = CityCompleterDataset()
    var users: [User] = []
    
    @Published var datePicked: Date = Date.now
    @Published var dateReturnPicked : Date = Date.now.addingTimeInterval(7 * 24 * 60 * 60) //seven days in ms
    @Published var oneWay: Bool = true
    @Published var outwardOptions: [[Segment]] = []
    @Published var returnOptions: [[Segment]] = []
    
    @Published var selectedOption: [Segment] = []
    
    @Published var predictedCities: [CityCompleterDataset] = []
    @Published var predictionShown: Int = 0
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol) {
        self.modelContext = modelContext
        self.serverService = serverService
    }
    
    // used after a travel search
    func resetParameters() {
        self.arrival = CityCompleterDataset()
        self.departure = CityCompleterDataset()
        self.datePicked = Date()
        self.selectedOption = []
        self.outwardOptions = []
        self.returnOptions = []
        self.predictedCities = []
    }
    
    func computeRoutes () async {
        self.outwardOptions = []
        self.returnOptions = []
        self.selectedOption = []
        let isOutward = true
        
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        timeFormatter.timeZone = TimeZone(identifier: "UTC")
        let formattedDate = dateFormatter.string(from: datePicked)
        let formattedDateReturn = dateFormatter.string(from: dateReturnPicked)
        let formattedTime = timeFormatter.string(from: datePicked)
        let formattedTimeReturn = timeFormatter.string(from: dateReturnPicked)
        
        // get outward options
        do {
            let outwardOptions = try await serverService.computeRoutes(departureIata: departure.iata, departureCountryCode: departure.countryCode, destinationIata: arrival.iata, destinationCountryCode: arrival.countryCode, date: formattedDate, time: formattedTime, isOutward: isOutward)
            self.outwardOptions = outwardOptions.options
        }catch {
            print("Error fetching options: \(error.localizedDescription)")
            return
        }
        
        // get return options
        if (!oneWay) {
            do {
                let returnOptions = try await serverService.computeRoutes(departureIata: arrival.iata, departureCountryCode: arrival.countryCode, destinationIata: departure.iata, destinationCountryCode: departure.countryCode, date: formattedDateReturn, time: formattedTimeReturn, isOutward: !isOutward)
                self.returnOptions = returnOptions.options
            }catch {
                print("Error fetching options: \(error.localizedDescription)")
            }
        }
    }
    
    func saveTravel() async {
        do {
            // build travel details
            users = try modelContext.fetch(FetchDescriptor<User>())
            guard let userID = users.first?.userID else {
                print("Missing user or user id")
                return
            }
            if self.selectedOption.isEmpty {
                print("Missing selected option")
                return
            }
            
            let travel = Travel(userID: userID)
            let travelDetails = TravelDetails(travel: travel, segments: selectedOption)
            
            // save on server
            let returnedTravelDetails = try await serverService.saveTravel(travelDetails: travelDetails)
            
            // save travel in SwiftData
            self.modelContext.insert(returnedTravelDetails.travel)
            for segment in returnedTravelDetails.segments {
                self.modelContext.insert(segment)
            }
            do {
                try self.modelContext.save()
            } catch {
                print("Error saving new travel: \(error.localizedDescription)")
                return
            }
            print("Travel added to SwiftData")
        }catch{
            print("Error saving travel: \(error.localizedDescription)")
            return
        }
        self.departure = CityCompleterDataset()
        self.arrival = CityCompleterDataset()
    }
    
    func computeCo2Emitted(_ travelOption: [Segment]) -> Float64 {
        return logic.computeCo2Emitted(travelOption)
    }
    
    func computeTotalPrice (_ travelOption: [Segment]) -> Float64 {
        return logic.computeTotalPrice(travelOption)
    }
    
    func computeGreenPrice(_ travelOption: [Segment]) -> Float64 {
        return logic.computeGreenPrice(travelOption)
    }
    
    func computeTotalDuration (_ travelOption: [Segment]) -> String {
        return logic.computeTotalDuration(travelOption)
    }
    
    func getOptionDeparture (_ travelOption: [Segment]) -> String {
        return logic.getOptionDeparture(travelOption)
    }
    
    func getOptionDestination (_ travelOption: [Segment]) -> String {
        return logic.getOptionDestination(travelOption)
    }
    
    func findVehicle(_ option: [Segment]) -> String {
        return logic.findVehicle(option)
    }
    
    func getNumTrees(_ travelOption: [Segment]) -> Int {
        return logic.getNumTrees(travelOption)
    }
    func computeTotalDistance(_ travelOption: [Segment]) -> Float64 {
        return logic.computeTotalDistance(travelOption)
    }
    func countChanges(_ option: [Segment]) -> Int {
        return logic.countChanges(option)
    }
}
