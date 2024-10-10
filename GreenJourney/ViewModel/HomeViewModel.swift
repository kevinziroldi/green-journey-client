import Foundation


class HomeViewModel: ObservableObject {
    private var userId: Int
    
    @Published var departure: String
    @Published var destination: String
    
    @Published var flightOption: Travel?
    @Published var busOption: Travel?
    @Published var trainOption: Travel?
    @Published var carOption: Travel?
    @Published var bikeOption: Travel?
    
    
    func computeRoutes (from departure: String, to destination: String, on date: Date) {
        guard let url = URL(string:"http://localhost:8080//travels/fromto?from=\(departure)&to=\(destination)&date=\(date)")
        else {
            //invalid url
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                //error occurred
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
    
    
    //TODO
    init() {
        self.userId = 1
        self.departure = ""
        self.destination = ""
    }
    
}
