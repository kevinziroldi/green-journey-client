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
    
    @Published var flightOption: [TravelDetails]
    @Published var busOption: [TravelDetails]
    @Published var trainOption: [TravelDetails]
    @Published var carOption: TravelDetails?
    @Published var bikeOption: TravelDetails?
    
    
    func computeRoutes (from departure: String, to destination: String, on date: Date) {
        guard let url = URL(string:"http://localhost:8080//travels/fromto?from=\(departure)&to=\(destination)&date=\(date)")
        else {
            //invalid url
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                //error occurred
                return
            }
            
            guard let data = data else {
                //no data received
                return
            }
            let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"   // date format
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)

                    do {
                        let travels = try decoder.decode([TravelDetails].self, from: data)
                        for travelDetail in travels {
                            if !travelDetail.segments.isEmpty {
                                if let vehicle = travelDetail.segments.first?.vehicle {
                                    switch vehicle {
                                    case Vehicle.car:
                                        self.carOption = travelDetail
                                    case Vehicle.bike:
                                        self.bikeOption = travelDetail
                                    case Vehicle.plane:
                                        self.flightOption.append(travelDetail)
                                    case Vehicle.bus:
                                        self.busOption.append(travelDetail)
                                    case Vehicle.train:
                                        self.trainOption.append(travelDetail)
                                    }
                                } else {
                                    continue
                                }
                            }
                        }
                        
                            
                        print(travels)
                    } catch {
                        print("Error decoding JSON: \(error.localizedDescription)")
                    }
                }
        task.resume()
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
        self.flightOption = []
        self.busOption = []
        self.trainOption = []
        self.carOption = nil
        self.bikeOption = nil
        self.completer = MKLocalSearchCompleter()
        //initialization of nsobject
        super.init()
        self.completer.delegate = self
        self.completer.resultTypes = [.address]
        
    }
            
}
