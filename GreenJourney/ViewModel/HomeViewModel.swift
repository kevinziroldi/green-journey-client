import Foundation
import MapKit

class HomeViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
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
    
    @Published var flightOption: [Segment]?
    @Published var busOption: [Segment]?
    @Published var trainOption: [Segment]?
    @Published var carOption: [Segment]?
    @Published var bikeOption: [Segment]?
    
    
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
            
            do {
                let travels = try JSONDecoder().decode(Travel.self, from: data)
                print(travels)
            } catch {
                //error in decoding data
                print("an error occurred decoding the JSON file!")
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
        print("Results updated: \(completer.results.count)")// Debug: mostra quanti risultati ci sono
        print(suggestions)
        self.suggestions = completer.results
    }
        
        func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            // error handling
            print("Errore durante il completamento della ricerca: \(error)")
        }
    
    init(userId: Int, flightOption: [Segment]? = nil, busOption: [Segment]? = nil, trainOption: [Segment]? = nil, carOption: [Segment]? = nil, bikeOption: [Segment]? = nil) {
        self.userId = userId
        self.completer = MKLocalSearchCompleter()
        //initialization of nsobject
        super.init()
        self.completer.delegate = self
        self.completer.resultTypes = [.address]
        self.datePicked = datePicked
        self.flightOption = flightOption
        self.busOption = busOption
        self.trainOption = trainOption
        self.carOption = carOption
        self.bikeOption = bikeOption
    }
    
            
}
