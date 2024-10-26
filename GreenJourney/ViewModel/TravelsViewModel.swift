import Foundation
import Combine

class TravelsViewModel: ObservableObject {
    @Published var travelDetails: [TravelDetails] = []
    private var cancellables = Set<AnyCancellable>()
    
    func fetchTravels(for userId: Int) {
        guard let url = URL(string:"http://192.168.1.43:8080//travels/user?id=\(userId)") else {
            print("Invalid URL")
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
           .decode(type: [TravelDetails].self, decoder: decoder)
           .receive(on: DispatchQueue.main)
           .sink(receiveCompletion: {
               completion in
               switch completion {
               case .finished:
                   break
               case .failure(let error):
                   print("Error fetching travels: \(error.localizedDescription)")
               }
           }, receiveValue: { [weak self] travelDetails in
               self?.travelDetails = travelDetails
           })
           .store(in: &cancellables)
        }
}
