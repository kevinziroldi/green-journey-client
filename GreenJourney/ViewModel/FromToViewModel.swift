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

class FromToViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    var modelContext: ModelContext
    @Published var departure: String = "" {
        didSet {
            updateSearchResults(for: departure)
        }
    }
    @Published var destination: String = "" {
        didSet {
            updateSearchResults(for: destination)
        }
    }
    var users: [User] = []
    
    private var departureCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var destinationCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @Published var suggestions: [MKLocalSearchCompletion] = []
    private var completer: MKLocalSearchCompleter
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
        self.completer = MKLocalSearchCompleter()
        //initialization of nsobject
        super.init()
        self.completer.delegate = self
        self.completer.resultTypes = .address
        let englishRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.509865, longitude: -0.118092), // London coordinates
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
        self.completer.region = englishRegion
    }
    
    func computeRoutes () {
        //REAL INTERACTION
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
        guard let url = URL(string:"\(baseURL)/travels/fromto?from=\(departure)&to=\(destination)&from_latitude=\(departureCoordinates.latitude)&from_longitude=\(departureCoordinates.longitude)&to_latitude=\(destinationCoordinates.latitude)&to_longitude=\(destinationCoordinates.longitude)&date=\(formattedDate)&time=\(formattedTime)&is_outward=\(isOutward)") else {
            return
        }
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
            guard let returnUrl = URL(string:"\(baseURL)/travels/fromto?from=\(destination)&to=\(departure)&from_latitude=\(destinationCoordinates.latitude)&from_longitude=\(destinationCoordinates.longitude)&to_latitude=\(departureCoordinates.latitude)&to_longitude=\(departureCoordinates.longitude)&date=\(formattedDateReturn)&time=\(formattedTimeReturn)&is_outward=\(!isOutward)") else {
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
        
        
    }
        
    func updateSearchResults(for query: String) {
        if query.isEmpty {
            // if the query string is empty those clean the suggestions list
            self.suggestions = []
        } else {
            // update with the new input
            self.completer.queryFragment = query
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        var seenCoordinates: [CLLocationCoordinate2D] = []
            var uniqueResults: [MKLocalSearchCompletion] = []
            let group = DispatchGroup() // to handle asyncronous requests
        let restrictedResults = completer.results.prefix(4)
        for result in restrictedResults {
                // filter to obtain only cities
                guard (!result.subtitle.contains(",") && (!result.subtitle.isEmpty || result.title.contains(","))) else {
                    continue
                }
                // add the asyncronus request to the group
                group.enter()
                // get coordinates for each unique result
                getCoordinates(for: result.title) { coordinate, error in
                    defer { group.leave() } // leave the group when it's ended

                    if let error = error {
                        print(error)
                        return
                    }
                    if let coordinate = coordinate {
                        let isDuplicate = seenCoordinates.contains { $0.latitude == coordinate.latitude && $0.longitude == coordinate.longitude }
                        if !isDuplicate {
                            // add coordinate to seenCoordinates
                            seenCoordinates.append(coordinate)
                            uniqueResults.append(result)
                        }
                    }
                }
            }

            // Update suggestions
            group.notify(queue: .main) {
                self.suggestions = uniqueResults
            }
    }
    
    private func getCoordinates(for city: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = city
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            if let error = error {
                completion(nil, error) // return the error
                return
            }
            
            // verify that there is at least one result
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                completion(nil, NSError(domain: "NoResults", code: 404, userInfo: [NSLocalizedDescriptionKey: "No results for this location"]))
                return
            }
            
            // return coordinate
            completion(coordinate, nil)
        }
    }
    
    func insertCoordinates () {
        getCoordinates(for: self.departure) { coordinate, error in
            if let error = error {
                print(error)
                return
            }
            else if let coordinate = coordinate {
                self.departureCoordinates = coordinate
            }
        }
        getCoordinates(for: self.destination) { coordinate, error in
            if let error = error {
                print(error)
                return
            }
            else if let coordinate = coordinate {
                self.destinationCoordinates = coordinate
            }
        }
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
        for segment in travelOption {
            hours += durationToHoursAndMinutes(duration: segment.duration).hours
            minutes += durationToHoursAndMinutes(duration: segment.duration).minutes
        }
        return "\(hours) h, \(minutes) min"
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
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // error handling
        print("error during completer search: \(error)")
    }
    
    func getRecommendation() {
        do {
            // fetch data from SwiftData
            let travels = try modelContext.fetch(FetchDescriptor<Travel>())
            let segments = try modelContext.fetch(FetchDescriptor<Segment>())
            let citiesDS = try modelContext.fetch(FetchDescriptor<CityDataset>())
            
            // build travel details list
            let segmentsByTravelID = Dictionary(grouping: segments, by: { $0.travelID })
            let travelDetailsList = travels.compactMap { travel in
                if let travelID = travel.travelID {
                    if let travelSegments = segmentsByTravelID[travelID] {
                        return TravelDetails(travel: travel, segments: travelSegments)
                    } else {
                        return TravelDetails(travel: travel, segments: [])
                    }
                }
                return nil
            }

            // get visited cities
            var visitedCities = Set<CityCountry>()
            for travelDetails in travelDetailsList {
                if let lastSegment = travelDetails.getLastSegment() {
                    visitedCities.insert(CityCountry(city: lastSegment.destinationCity, country: lastSegment.destinationCountry))
                }
            }
            
            // feature values
            var populationValues: [Double] = []
            var capitalValues: [Bool] = []
            var averageTemperatureValues: [Double] = []
            var continentValues: [String] = []
            var livingCostValues: [Double] = []
            var travelConnectivityValues: [Double] = []
            var safetyValues: [Double] = []
            var healthcareValues: [Double] = []
            var educationValues: [Double] = []
            var economyValues: [Double] = []
            var internetAccessValues: [Double] = []
            var outdoorsValues: [Double] = []
            
            // get cities in the dataset for visited cities (destination)
            for cityCountry in visitedCities {
                for cityDS in citiesDS {
                    if cityCountry.city == cityDS.city &&
                        cityCountry.country == cityDS.country {
                        populationValues.append(cityDS.population)
                        capitalValues.append(cityDS.capital)
                        averageTemperatureValues.append(cityDS.averageTemperature)
                        continentValues.append(cityDS.continent)
                        livingCostValues.append(cityDS.livingCost)
                        travelConnectivityValues.append(cityDS.travelConnectivity)
                        safetyValues.append(cityDS.safety)
                        healthcareValues.append(cityDS.healthcare)
                        educationValues.append(cityDS.education)
                        economyValues.append(cityDS.economy)
                        internetAccessValues.append(cityDS.internetAccess)
                        outdoorsValues.append(cityDS.outdoors)
                    }
                }
            }
            
            // compute feature values
            // var because I possibly need to make more predictions
            let population = calculateMedian(populationValues)
            
            var capital = false
            var numCapital = 0
            var numNotCapital = 0
            for capitalValue in capitalValues {
                if capitalValue {
                    numCapital += 1
                }else {
                    numNotCapital += 1
                }
            }
            if numCapital >= numNotCapital {
                capital = true
            }
            
            let averageTemperature = calculateMedian(averageTemperatureValues)
            
            var continentFrequency: [String: Int] = [:]
            for continent in continentValues {
                continentFrequency[continent, default: 0] += 1
            }
            let continent = continentFrequency.max(by: { $0.value < $1.value })?.key ?? "Europe"

            let livingCost = calculateMedian(livingCostValues)
            let travelConnectivity = calculateMedian(travelConnectivityValues)
            let safety = calculateMedian(safetyValues)
            let healthcare = calculateMedian(healthcareValues)
            let education = calculateMedian(educationValues)
            let economy = calculateMedian(economyValues)
            let internetAccess = calculateMedian(internetAccessValues)
            let outdoors = calculateMedian(outdoorsValues)
            
            // use model to make a prediction
            let citiesIds = predictCity(population: population, capital: capital, averageTemperature: averageTemperature, continent: continent, livingCost: livingCost, travelConnectivity: travelConnectivity, safety: safety, healthcare: healthcare, education: education, economy: economy, internetAccess: internetAccess, outdoors: outdoors)
            
            // check which is the first non visited city
            // if all visited, return the first visited one (in time)
            for cityId in citiesIds {
                if let cityDS = citiesDS.first(where: { $0.id == cityId }) {
                    let cityCountrySearch = CityCountry(city: cityDS.city, country: cityDS.country)
                    if !visitedCities.contains(cityCountrySearch) {
                        self.destination = cityCountrySearch.city
                        
                        
                        // TODO set also country !!!
                        
                        
                        return
                    }
                }
            }
            
            // else return the first one
            if let cityId = citiesIds.first {
                if let firstCity = citiesDS.first(where: { $0.id == cityId }) {
                    self.destination = firstCity.city
                    
                    // TODO set also country !!!
                    
                    return
                }
            }
            
            // if not present, return a default
            self.destination = "Paris"
            // TODO set also country !!!
            
            
        }catch {
            
            // TODO
            
            print("Error interacting with SwiftData")
            
        }
    }
    
    /*
    private func getLastSegment(travelDetails: TravelDetails) -> Segment? {
        if let firstListSegment = travelDetails.segments.first {
            var lastSegment = firstListSegment
            for segment in travelDetails.segments {
                if segment.numSegment > lastSegment.numSegment {
                    lastSegment = segment
                }
            }
            return lastSegment
        }
        return nil
    }
     */
    
    private func calculateMedian(_ values: [Double]) -> Double {
        let sortedValues = values.sorted()
        if sortedValues.count % 2 == 0 {
            return (sortedValues[sortedValues.count / 2 - 1] + sortedValues[sortedValues.count / 2]) / 2
        } else {
            return sortedValues[sortedValues.count / 2]
        }
    }
    
    private func predictCity(population: Double, capital: Bool, averageTemperature: Double, continent: String, livingCost: Double, travelConnectivity: Double, safety: Double, healthcare: Double, education: Double, economy: Double, internetAccess: Double, outdoors: Double) -> [Int64] {
        
        do {
            let config = MLModelConfiguration()
            let model = try GreenJourneyMLModel(configuration: config)
            let prediction = try model.prediction(
                population: population,
                capital: Int64(capital),
                average_temperature:averageTemperature,
                continent:continent,
                living_cost:livingCost,
                travel_connectivity:travelConnectivity,
                safety:safety,
                healthcare:healthcare,
                education:education,
                economy:economy,
                internet_access:internetAccess,
                outdoors:outdoors
            )
            
            let maxDepth = 30
            let cityProbabilities = prediction.idProbability
            let sortedProbabilities = cityProbabilities.sorted(by: { $0.value > $1.value })
            let topProbabilities = sortedProbabilities.prefix(maxDepth)
            var citiesId: [Int64] = []
            for probability in topProbabilities {
                citiesId.append(probability.key)
            }
            
            return citiesId
        }catch{
            return ([])
        }
    }
}

extension Int64 {
    init(_ bool: Bool) {
        if bool {
            self = 1
        }
        self = 0
    }
}
