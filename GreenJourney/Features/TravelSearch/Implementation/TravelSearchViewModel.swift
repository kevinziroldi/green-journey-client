import Combine
import CoreML
import Foundation
import MapKit
import SwiftData

struct OptionsResponse: Decodable {
    let options: [[Segment]]
}

struct CityCountry: Hashable {
    let city: String
    let country: String
}

class TravelSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    var modelContext: ModelContext
    @Published var departure: CityCompleterDataset = CityCompleterDataset()
    @Published var arrival: CityCompleterDataset = CityCompleterDataset()
    var users: [User] = []
    
    @Published var datePicked: Date = Date.now
    @Published var dateReturnPicked : Date = Date.now.addingTimeInterval(7 * 24 * 60 * 60) //seven days in ms
    @Published var oneWay: Bool = true
    @Published var outwardOptions: [[Segment]] = []
    @Published var returnOptions: [[Segment]] = []
    
    @Published var selectedOption: [Segment] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        do {
            users = try modelContext.fetch(FetchDescriptor<User>())
        }catch {}
    }
    
    func computeRoutes () {
        self.outwardOptions = []
        self.returnOptions = []
        self.selectedOption = []
        let isOutward = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let formattedDate = dateFormatter.string(from: datePicked)
        let formattedDateReturn = dateFormatter.string(from: dateReturnPicked)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let formattedTime = timeFormatter.string(from: datePicked)
        let formattedTimeReturn = timeFormatter.string(from: dateReturnPicked)
        let baseURL = NetworkManager.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/travels/search?iata_departure=\(departure.locode)&country_code_departure=\(departure.countryCode)&iata_destination=\(arrival.locode)&country_code_destination=\(arrival.countryCode)&date=\(formattedDate)&time=\(formattedTime)&is_outward=\(isOutward)") else {
            return
        }
        
        print("URL:  \(url)")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap {
                result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                print(String(data: result.data, encoding: .utf8) ?? "No data")
                
                return result.data
            }
            .decode(type: OptionsResponse.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching options: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] response in
                self?.outwardOptions = response.options
            })
            .store(in: &cancellables)
        if (!oneWay) {
            guard let returnUrl = URL(string:"\(baseURL)/travels/search?iata_departure=\(arrival.locode)&country_code_departure=\(arrival.countryCode)&iata_destination=\(departure.locode)&country_code_destination=\(departure.countryCode)&date=\(formattedDateReturn)&time=\(formattedTimeReturn)&is_outward=\(!isOutward)") else {
                return
            }
            URLSession.shared.dataTaskPublisher(for: returnUrl)
                .tryMap {
                    result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                    
                    print(String(data: result.data, encoding: .utf8) ?? "No data")
                    
                    return result.data
                }
                .decode(type: OptionsResponse.self, decoder: decoder)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: {
                    completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error fetching options: \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] response in
                    self?.returnOptions = response.options
                })
                .store(in: &cancellables)
        }
         
    }
    
    func saveTravel() {
        // save travel on server
        let baseURL = NetworkManager.shared.getBaseURL()
        guard let url = URL(string: "\(baseURL)/travels/user") else {
            print("Invalid URL for posting user data to DB")
            return
        }
        let travel = Travel(userID: users.first!.userID!)
        var travelDetails = TravelDetails(travel: travel, segments: selectedOption)
        // JSON encoding
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let body = try? encoder.encode(travelDetails) else {
            print("Error encoding travel data")
            return
        }
        print("body: " , String(data: body, encoding: .utf8)!)
        
        
        // POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        URLSession.shared.dataTaskPublisher(for: request)
            .retry(2)
            .tryMap {
                result -> Data in
                // check status of response
                guard let httpResponse = result.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .receive(on: DispatchQueue.main)
            .decode(type: TravelDetails.self, decoder: decoder)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Travel data posted successfully.")
                case .failure(let error):
                    print("Error posting travel data: \(error.localizedDescription)")
                    return
                }
            }, receiveValue: { response in
                travelDetails = response
                
                // save travel in SwiftData
                self.modelContext.insert(travelDetails.travel)
                for segment in travelDetails.segments {
                    self.modelContext.insert(segment)
                }
                do {
                    try self.modelContext.save()
                } catch {
                    
                    // TODO gestione
                    
                    print("Error saving new travel: \(error.localizedDescription)")
                    return
                }
                print("travel added to SwiftData")
            })
            .store(in: &cancellables)
        departure = CityCompleterDataset()
        arrival = CityCompleterDataset()
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
