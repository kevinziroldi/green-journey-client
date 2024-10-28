import Foundation
import Combine

class TravelsViewModel: ObservableObject {
    @Published var travelDetails: [TravelDetails] = []
    private var cancellables = Set<AnyCancellable>()
    
    func fetchTravels(for userId: Int) {
        
        // TODO IP e porta non qua
        
        guard let url = URL(string:"http://192.168.1.41:8080//travels/user?id=\(userId)") else {
            print("Invalid URL used to retrieve travels from DB")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        URLSession.shared.dataTaskPublisher(for: url)
            .retry(2)
            .tryMap {
                result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
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
