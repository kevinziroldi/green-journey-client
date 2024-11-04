import Foundation
import MapKit
import Combine

class FromToViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    private var userId: Int
    
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
    
    @Published var suggestions: [MKLocalSearchCompletion] = []
    private var completer: MKLocalSearchCompleter
    @Published var datePicked: Date = Date.now
    @Published var dateReturnPicked : Date = Date.now.addingTimeInterval(7 * 24 * 60 * 60) //seven days in ms
    @Published var oneWay: Bool = true
    
    @Published var travelOptions: TravelOptions = TravelOptions(outwardOptions: [], returnOptions: [])
    
    @Published var selectedOption: [Segment] = []
    private var cancellables = Set<AnyCancellable>()
    
    
    func computeRoutes (from departure: String, to destination: String, on date: Date, return returnDate: Date, oneWay oneway: Bool) {
        //MOCK INTERACTION
        /*let jsonString = """
         {"outwardOptions":[[{"segment_id":-1,"departure":"Milan, Metropolitan City of Milan, Italy","destination":"Paris, France","date":"2024-10-21T00:00:00Z","time":"0000-01-01T15:00:00Z","duration":165205000000000,"vehicle":"bike","description":"","price":0,"co2_emitted":0,"distance":864,"num_segment":1,"is_outbound":true,"travel_id":-1}],[{"segment_id":-1,"departure":"Milan, Metropolitan City of Milan, Italy","destination":"Paris, France","date":"2024-10-21T00:00:00Z","time":"0000-01-01T15:00:00Z","duration":33503000000000,"vehicle":"car","description":"","price":159.32,"co2_emitted":182.20000000000002,"distance":911.075,"num_segment":1,"is_outbound":true,"travel_id":-1}],[{"segment_id":0,"departure":"Milano Centrale Railway Station","destination":"Lausanne","date":"2024-10-21T19:20:00+02:00","time":"2024-10-21T19:20:00+02:00","duration":13800000000000,"vehicle":"train","description":"EC, Eurocity","price":100,"co2_emitted":10.045000000000002,"distance":287.735,"num_segment":1,"is_outbound":true,"travel_id":0},{"segment_id":0,"departure":"","destination":"","date":"1970-01-01T01:00:00+01:00","time":"1970-01-01T01:00:00+01:00","duration":17000000000,"vehicle":"walk","description":"","price":0,"co2_emitted":0,"distance":16,"num_segment":2,"is_outbound":true,"travel_id":0},{"segment_id":0,"departure":"Lausanne","destination":"Delemonte","date":"2024-10-21T23:14:00+02:00","time":"2024-10-21T23:14:00+02:00","duration":5640000000000,"vehicle":"train","description":"IC, ","price":100,"co2_emitted":5.040000000000001,"distance":144.808,"num_segment":3,"is_outbound":true,"travel_id":0},{"segment_id":0,"departure":"","destination":"","date":"1970-01-01T01:00:00+01:00","time":"1970-01-01T01:00:00+01:00","duration":122000000000,"vehicle":"walk","description":"","price":0,"co2_emitted":0,"distance":122,"num_segment":4,"is_outbound":true,"travel_id":0},{"segment_id":0,"departure":"Delemonte","destination":"Belfort - Montbéliard","date":"2024-10-22T04:49:00+02:00","time":"2024-10-22T04:49:00+02:00","duration":4020000000000,"vehicle":"train","description":"TER, Belfort - Delle","price":100,"co2_emitted":1.8900000000000001,"distance":54.595,"num_segment":5,"is_outbound":true,"travel_id":0},{"segment_id":0,"departure":"Belfort - MontbÃ©️liard","destination":"Gare de Lyon","date":"2024-10-22T06:11:00+02:00","time":"2024-10-22T06:11:00+02:00","duration":9300000000000,"vehicle":"train","description":"TGV INOUI, Paris - Mulhouse Via Besanon TGV","price":100,"co2_emitted":15.505,"distance":443.097,"num_segment":6,"is_outbound":true,"travel_id":0}],[{"segment_id":0,"departure":"Milan Lampugnano","destination":"Paris City Centre - Bercy Seine","date":"2024-10-21T17:30:00+02:00","time":"2024-10-21T17:30:00+02:00","duration":45600000000000,"vehicle":"bus","description":"BlaBlaCar Bus, Paris City Centre - Bercy Seine > Geneva - Bus station > Milan","price":100,"co2_emitted":19.5,"distance":650.799,"num_segment":1,"is_outbound":true,"travel_id":0}],[{"segment_id":0,"departure":"MILAN","destination":"PARIS","date":"2024-10-21T20:10:00Z","time":"0001-01-01T00:00:00Z","duration":5700000000000,"vehicle":"plane","description":"VY 8431","price":122.23,"co2_emitted":148.7058823529412,"distance":590.791143770483,"num_segment":1,"is_outbound":true,"travel_id":0}],[{"segment_id":0,"departure":"MILAN","destination":"PARIS","date":"2024-10-21T20:10:00Z","time":"0001-01-01T00:00:00Z","duration":5700000000000,"vehicle":"plane","description":"IB 5777","price":134.23,"co2_emitted":148.7058823529412,"distance":590.791143770483,"num_segment":1,"is_outbound":true,"travel_id":0}]],"returnOptions":null}
         
         """*/
        //REAL INTERACTION
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let formattedDate = dateFormatter.string(from: date)
        let formattedDateReturn = dateFormatter.string(from: returnDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let formattedTime = timeFormatter.string(from: date)
        let formattedTimeReturn = timeFormatter.string(from: returnDate)
        var url: URL?
        let baseURL = NetworkManager.shared.getBaseURL()
        if (oneway) {
            url = URL(string:"\(baseURL)/travels/fromto?from=\(departure)&to=\(destination)&dateOutward=\(formattedDate)&timeOutward=\(formattedTime)&round_trip=\(!oneWay)")
        }
        else {
            url = URL(string:"\(baseURL)/travels/fromto?from=\(departure)&to=\(destination)&dateOutward=\(formattedDate)&timeOutward=\(formattedTime)&round_trip=\(!oneWay)&dateReturn=\(formattedDateReturn)&timeReturn=\(formattedTimeReturn)")
        }
        guard let validUrl = url else {
            print("Invalid URL from to")
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        URLSession.shared.dataTaskPublisher(for: validUrl)
           .tryMap {
               result -> Data in
               guard let httpResponse = result.response as? HTTPURLResponse,
                     (200...299).contains(httpResponse.statusCode) else {
                   throw URLError(.badServerResponse)
               }
               
               print(String(data: result.data, encoding: .utf8) ?? "No data")
               
               return result.data
           }
           .decode(type: TravelOptions.self, decoder: decoder)
           .receive(on: DispatchQueue.main)
           .sink(receiveCompletion: {
               completion in
               switch completion {
               case .finished:
                   break
               case .failure(let error):
                   print("Error fetching travels: \(error.localizedDescription)")
               }
           }, receiveValue: { [weak self] travelOptions in
               self?.travelOptions = travelOptions
           })
           .store(in: &cancellables)
    }
         
        
        //MOCK INTERACTION
        /*let decoder = JSONDecoder()
        if let data = jsonString.data(using: .utf8){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"   // date format
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
                do {
                    let travelOptions = try decoder.decode(TravelOptions.self, from: data)
                    self.outwardOptions = travelOptions.outwardOptions
                    self.returnOptions = travelOptions.returnOptions
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Chiave '\(key)' mancante:", context.debugDescription)
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Tipo non corrispondente per tipo \(type):", context.debugDescription)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Valore mancante per \(value):", context.debugDescription)
                } catch let DecodingError.dataCorrupted(context) {
                    print("Dati corrotti:", context.debugDescription)
                } catch {
                    print("Errore: \(error.localizedDescription)")
                }
        }
    }*/
        
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
        // result update
        var seenCities: Set<String> = []
        self.suggestions = completer.results
            .filter { result in
                if !seenCities.contains(result.title) {
                    seenCities.insert(result.title)
                    return true
                }
                return false
            }
            .filter {result in
                if (!result.subtitle.contains(",") && !result.subtitle.isEmpty) {
                    return true
                }
                return false
            }
            .prefix(4) // max 4 results
            .map { $0 } // remove duplicates
        print(suggestions)
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
        let hours = duration / (3600 * 1000000000)       // 1 ora = 3600 secondi
        let remainingSeconds = (duration / 1000000000) % (3600)
        let minutes = remainingSeconds / 60  // 1 minuto = 60 secondi
        
        return (hours, minutes)
    }
    
    func getOptionDeparture (_ travelOption: [Segment]) -> String {
        if let firstSegment = travelOption.first {
            return firstSegment.departure
        }
        else {
            return ""
        }
    }
    
    func getOptionDestination (_ travelOption: [Segment]) -> String {
        if let lastSegment = travelOption.last {
            return lastSegment.destination
        }
        else {
            return ""
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // error handling
        print("Errore durante il completamento della ricerca: \(error)")
    }
    
    init(userId: Int) {
        self.userId = userId
        self.completer = MKLocalSearchCompleter()
        //initialization of nsobject
        super.init()
        self.completer.delegate = self
        self.completer.resultTypes = .address
        let englishRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.509865, longitude: -0.118092), // Coordinate di Londra
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
        self.completer.region = englishRegion
        
    }
    
    struct TravelOptions: Decodable {
        var outwardOptions: [[Segment]]
        var returnOptions: [[Segment]]?
        enum CodingKeys: String, CodingKey {
            case outwardOptions = "outward_options"
            case returnOptions = "return_options"
        }
    }
    
}
