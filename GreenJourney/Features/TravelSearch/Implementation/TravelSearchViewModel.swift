import Combine
import CoreML
import Foundation
import MapKit
import SwiftData

@MainActor
class TravelSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    private let uuid: UUID = UUID()
    
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    
    @Published var departure: CityCompleterDataset = CityCompleterDataset()
    @Published var arrival: CityCompleterDataset = CityCompleterDataset()
    var users: [User] = []
    
    @Published var datePicked: Date = Date.now
    @Published var dateReturnPicked : Date = Date.now.addingTimeInterval(7 * 24 * 60 * 60) //seven days in ms
    @Published var oneWay: Bool = true
    @Published var outwardOptions: [TravelOption] = []
    @Published var returnOptions: [TravelOption] = []
    
    @Published var selectedOption: [Segment] = []
    
    @Published var predictedCities: [CityCompleterDataset] = []
    @Published var predictionShown: Int = 0
    @Published var optionsAvailable: Bool = false
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol) {
        self.modelContext = modelContext
        self.serverService = serverService
    }
    
    // used after a travel search
    func resetParameters() {
        self.arrival = CityCompleterDataset()
        self.departure = CityCompleterDataset()
        self.datePicked = Date()
        dateReturnPicked = Date.now.addingTimeInterval(7 * 24 * 60 * 60)
        self.predictedCities = []
    }
    
    func computeRoutes () async {
        optionsAvailable = false
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
            self.outwardOptions = outwardOptions
            
            // get return options
            if (!oneWay) {
                let returnOptions = try await serverService.computeRoutes(departureIata: arrival.iata, departureCountryCode: arrival.countryCode, destinationIata: departure.iata, destinationCountryCode: departure.countryCode, date: formattedDateReturn, time: formattedTimeReturn, isOutward: !isOutward)
                self.returnOptions = returnOptions
            }
            optionsAvailable = true
        }catch {
            print("Error fetching options: \(error.localizedDescription)")
            optionsAvailable = true
            return
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
}
