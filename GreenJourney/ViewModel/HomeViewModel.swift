import Foundation


class HomeViewModel: ObservableObject {
    private var userId: Int
    
    @Published var departure: String?
    @Published var destination: String?
    @Published var datePicked: Date?
    
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
    init(userId: Int, departure: String? = nil, destination: String? = nil, datePicked: Date? = nil, flightOption: [Segment]? = nil, busOption: [Segment]? = nil, trainOption: [Segment]? = nil, carOption: [Segment]? = nil, bikeOption: [Segment]? = nil) {
        self.userId = userId
        self.departure = departure
        self.destination = destination
        self.datePicked = datePicked
        self.flightOption = flightOption
        self.busOption = busOption
        self.trainOption = trainOption
        self.carOption = carOption
        self.bikeOption = bikeOption
    }
    
}
