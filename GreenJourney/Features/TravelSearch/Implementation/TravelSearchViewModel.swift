import Combine
import CoreML
import Foundation
import MapKit
import SwiftData

class TravelSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    let uuid: UUID = UUID()
    
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    
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
    private func resetParameters() {
        self.arrival = CityCompleterDataset()
        self.departure = CityCompleterDataset()
        self.datePicked = Date()
        self.selectedOption = []
        self.outwardOptions = []
        self.returnOptions = []
        self.predictedCities = []
    }
    
    @MainActor
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
    
    @MainActor
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
            
            // after building travel details, I can reset
            resetParameters()
            
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
        var co2Emitted: Float64 = 0.0
        for segment in travelOption {
            co2Emitted += segment.co2Emitted
        }
        return co2Emitted
    }
    
    func computeTotalPrice (_ travelOption: [Segment]) -> Float64 {
        var price: Float64 = 0.0
        for segment in travelOption {
            price += segment.price
        }
        return price
    }
    
    func computeTotalDuration (_ travelOption: [Segment]) -> String {
        var hours: Int = 0
        var minutes: Int = 0
        var days: Int = 0
        for segment in travelOption {
            hours += durationToHoursAndMinutes(duration: segment.duration).hours
            minutes += durationToHoursAndMinutes(duration: segment.duration).minutes
        }
        while (minutes >= 60) {
            hours += 1
            minutes -= 60
        }
        while (hours >= 24) {
            days += 1
            hours -= 24
        }
        if (days == 0) {
            return "\(hours) h, \(minutes) min"
        }
        return "\(days) d, \(hours) h, \(minutes) min"
    }
    
    func durationToHoursAndMinutes(duration: Int) -> (hours: Int, minutes: Int) {
        let hours = duration / (3600 * 1000000000)       // 1 hour = 3600 secsecondsondi
        let remainingSeconds = (duration / 1000000000) % (3600)
        let minutes = remainingSeconds / 60  // 1 minute = 60 seconds
        
        return (hours, minutes)
    }
    
    func getOptionDeparture (_ travelOption: [Segment]) -> String {
        if let firstSegment = travelOption.first {
            return firstSegment.departureCity
        }
        else {
            return ""
        }
    }
    
    func getOptionDestination (_ travelOption: [Segment]) -> String {
        if let lastSegment = travelOption.last {
            return lastSegment.destinationCity
        }
        else {
            return ""
        }
    }
    
    func findVehicle(_ option: [Segment]) -> String {
        var vehicle: String
        switch option.first?.vehicle {
        case .car:
            vehicle = "car"
        case .train:
            vehicle = "tram"
        case .plane:
            vehicle = "airplane"
        case .bus:
            vehicle = "bus"
        case .walk:
            vehicle = "figure.walk"
        case .bike:
            vehicle = "bicycle"
        default:
            vehicle = ""
        }
        return vehicle
    }
}
