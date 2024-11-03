import Foundation
import Combine

class TravelsViewModel: ObservableObject {
    @Published var travelDetails: [TravelDetails] = []
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showCompleted = true
    
    func fetchTravels(for userId: Int) {
        print("MAKE CALL")
        
        let baseURL = NetworkManager.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/travels/user?id=\(userId)") else {
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
        
        print("SIZE TRAVELDETAILS: " + String(travelDetails.count))
        if travelDetails.count > 0 {
            print("\(travelDetails[0].segments.first?.departure ?? "Unknown")")
            print("\(travelDetails[0].segments.last?.destination ?? "Unknown")")
        }
    }
}
