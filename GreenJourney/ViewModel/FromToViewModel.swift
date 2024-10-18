import Foundation
import MapKit

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
    
    @Published var outwardOptions: [[Segment]]?
    @Published var returnOptions: [[Segment]]?
    
    @Published var selectedOption: [Segment] = []
    
    
    
    func computeRoutes (from departure: String, to destination: String, on date: Date, return returnDate: Date, oneWay oneway: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let formattedDate = dateFormatter.string(from: date)
        let formattedDateReturn = dateFormatter.string(from: returnDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let jsonString = """
            {
              "from": "Milan",
              "to": "Rome",
              "date": "2024-10-16",
              "time": "10:31",
              "outwardOptions": [
                [
                  {
                    "segment_id": -1,
                    "departure": "Milan, Metropolitan City of Milan, Italy",
                    "destination": "Rome, Metropolitan City of Rome Capital, Italy",
                    "date": "2024-10-16T00:00:00Z",
                    "duration": 132832000000000,
                    "vehicle": "bike",
                    "description": "",
                    "price": 0,
                    "co2_emitted": 0,
                    "distance": 672,
                    "num_segment": 1,
                    "is_outbound": true,
                    "travel_id": -1
                  }
                ],
                [
                  {
                    "segment_id": -1,
                    "departure": "Milan, Metropolitan City of Milan, Italy",
                    "destination": "London, UK",
                    "date": "2024-10-16T00:00:00Z",
                    "duration": 49241000000000,
                    "vehicle": "car",
                    "description": "",
                    "price": 193.4,
                    "co2_emitted": 239,
                    "distance": 1195.939,
                    "num_segment": 1,
                    "is_outbound": true,
                    "travel_id": -1
                  }
                ],
                [
                  {
                    "segment_id": 0,
                    "departure": "Milano Centrale Railway Station",
                    "destination": "Lugano",
                    "date": "2024-10-11T20:43:00+02:00",
                    "duration": 4500000000000,
                    "vehicle": "train",
                    "description": "RE80, Locarno - Chiasso - Como - Milano",
                    "price": 100,
                    "co2_emitted": 2.66,
                    "distance": 76.23,
                    "num_segment": 1,
                    "is_outbound": true,
                    "travel_id": 0
                  },
                  {
                    "segment_id": 0,
                    "departure": "",
                    "destination": "",
                    "date": "1970-01-01T01:00:00+01:00",
                    "duration": 172000000000,
                    "vehicle": "train",
                    "description": ", ",
                    "price": 100,
                    "co2_emitted": 0,
                    "distance": 0.172,
                    "num_segment": 2,
                    "is_outbound": true,
                    "travel_id": 0
                  },
                  {
                    "segment_id": 0,
                    "departure": "Lugano",
                    "destination": "Basel SBB",
                    "date": "2024-10-11T22:02:00+02:00",
                    "duration": 10800000000000,
                    "vehicle": "train",
                    "description": "IC21, ",
                    "price": 100,
                    "co2_emitted": 8.89,
                    "distance": 254.968,
                    "num_segment": 3,
                    "is_outbound": true,
                    "travel_id": 0
                  },
                  {
                    "segment_id": 0,
                    "departure": "",
                    "destination": "",
                    "date": "1970-01-01T01:00:00+01:00",
                    "duration": 394000000000,
                    "vehicle": "train",
                    "description": ", ",
                    "price": 100,
                    "co2_emitted": 0,
                    "distance": 0.431,
                    "num_segment": 4,
                    "is_outbound": true,
                    "travel_id": 0
                  },
                  {
                    "segment_id": 0,
                    "departure": "Basel SBB",
                    "destination": "Delemonte",
                    "date": "2024-10-12T03:45:00+02:00",
                    "duration": 2340000000000,
                    "vehicle": "train",
                    "description": "S3, ",
                    "price": 100,
                    "co2_emitted": 1.33,
                    "distance": 38.039,
                    "num_segment": 5,
                    "is_outbound": true,
                    "travel_id": 0
                  },
                  {
                    "segment_id": 0,
                    "departure": "",
                    "destination": "",
                    "date": "1970-01-01T01:00:00+01:00",
                    "duration": 122000000000,
                    "vehicle": "train",
                    "description": ", ",
                    "price": 100,
                    "co2_emitted": 0,
                    "distance": 0.122,
                    "num_segment": 6,
                    "is_outbound": true,
                    "travel_id": 0
                  },
                  {
                    "segment_id": 0,
                    "departure": "Delemonte",
                    "destination": "Belfort - Montbéliard",
                    "date": "2024-10-12T04:49:00+02:00",
                    "duration": 4020000000000,
                    "vehicle": "train",
                    "description": "TER, Belfort - Delle",
                    "price": 100,
                    "co2_emitted": 1.89,
                    "distance": 54.595,
                    "num_segment": 7,
                    "is_outbound": true,
                    "travel_id": 0
                  },
                  {
                    "segment_id": 0,
                    "departure": "Belfort - Montbéliard",
                    "destination": "Gare de Lyon",
                    "date": "2024-10-12T06:05:00+02:00",
                    "duration": 9420000000000,
                    "vehicle": "train",
                    "description": "TGV INOUI, Paris - Mulhouse Via Besançon TGV",
                    "price": 100,
                    "co2_emitted": 15.505,
                    "distance": 443.097,
                    "num_segment": 8,
                    "is_outbound": true,
                    "travel_id": 0
                  }
                ],
                [
                  {
                    "segment_id": 0,
                    "departure": "Milan Lampugnano",
                    "destination": "Paris City Centre - Bercy Seine",
                    "date": "2024-10-14T17:30:00+02:00",
                    "duration": 45600000000000,
                    "vehicle": "bus",
                    "description": "BlaBlaCar Bus, Paris City Centre - Bercy Seine > Geneva - Bus station > Milan",
                    "price": 100,
                    "co2_emitted": 19.5,
                    "distance": 650.799,
                    "num_segment": 1,
                    "is_outbound": true,
                    "travel_id": 0
                  }
                ],
                [
                  {
                    "segment_id": 0,
                    "departure": "MILAN",
                    "destination": "PARIS",
                    "date": "2024-10-10T09:45:00Z",
                    "duration": 5400000000000,
                    "vehicle": "plane",
                    "description": "IB 5775",
                    "price": 136.23,
                    "co2_emitted": 148.7058823529412,
                    "distance": 590.791143770483,
                    "num_segment": 1,
                    "is_outbound": true,
                    "travel_id": 0
                  }
                ],
                [
                  {
                    "segment_id": 0,
                    "departure": "MILAN",
                    "destination": "Rome",
                    "date": "2024-10-10T14:55:00Z",
                    "duration": 5400000000000,
                    "vehicle": "plane",
                    "description": "IB 9876",
                    "price": 196.23,
                    "co2_emitted": 148.7058823529412,
                    "distance": 590.791143770483,
                    "num_segment": 1,
                    "is_outbound": true,
                    "travel_id": 0
                  }
                ]
              ],
              "returnOptions": []
            }

            """
        
        let formattedTime = timeFormatter.string(from: date)
        let formattedTimeReturn = timeFormatter.string(from: returnDate)
        /*var url: URL?
         if (oneway) {
         url = URL(string:"http://192.168.89.25:8080//travels/fromto?from=\(departure)&to=\(destination)&dateOutward=\(formattedDate)&timeOutward=\(formattedTime)&round_trip=\(!oneWay)")
         }
         else {
         url = URL(string:"http://localhost:8080//travels/fromto?from=\(departure)&to=\(destination)&dateOutward=\(formattedDate)&timeOutward=\(formattedTime)&round_trip=\(!oneWay)&dateReturn=\(formattedDateReturn)&timeReturn=\(formattedTimeReturn)")
         }
         guard let validUrl = url else {
         //invalid url
         return
         }
         let task = URLSession.shared.dataTask(with: validUrl) { data, response, error in
         if let error = error {
         //error occurred
         return
         }
         
         guard let data = data else {
         //no data received
         return
         }*/
        
        let decoder = JSONDecoder()
        if let data = jsonString.data(using: .utf8) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"   // date format
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            /*do {
                let travelOptions = try decoder.decode(TravelOptions.self, from: data)*/
                do {
                    let travelOptions = try decoder.decode(TravelOptions.self, from: data)
                    print(travelOptions)
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
                /*self.outwardOptions = travelOptions.outwardOptions
                self.returnOptions = travelOptions.returnOptions
                
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }*/
        }
    //}
        //task.resume()
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
            .prefix(4) // max 4 results
            .map { $0 } // remove duplicates
        print(suggestions)
    }
        
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // error handling
        print("Errore durante il completamento della ricerca: \(error)")
    }
    
    init(userId: Int) {
        self.userId = userId
        self.outwardOptions = nil
        self.returnOptions = nil
        self.completer = MKLocalSearchCompleter()
        //initialization of nsobject
        super.init()
        self.completer.delegate = self
        self.completer.resultTypes = [.address]
        
    }
    
    struct TravelOptions: Decodable {
        let from: String
        let to: String
        let date: String
        let time: String
        var outwardOptions: [[Segment]]?
        var returnOptions: [[Segment]]?
    }
}
