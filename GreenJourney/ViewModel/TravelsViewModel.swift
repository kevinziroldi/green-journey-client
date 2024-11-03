import Foundation
import Combine

enum SortOption {
    case departureDate
    case price
    case co2Emitted
    case co2CompensationRate
}

class TravelsViewModel: ObservableObject {
    var travelDetails: [TravelDetails] = [] {
        didSet {
            filterTravelDetails()
        }
    }
    @Published var filteredTravelDetails: [TravelDetails] = []
    @Published var showCompleted = true {
        didSet {
            filterTravelDetails()
        }
    }
    private var cancellables = Set<AnyCancellable>()
    @Published var sortOption = SortOption.departureDate {
        didSet {
            sortTravels(by: sortOption)
        }
    }
        
    func fetchTravels(for userId: Int) {
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
    }
    
    private func filterTravelDetails() {
        let currentDate = Date()
        filteredTravelDetails = travelDetails.filter { travel in
            let durationSeconds = Double((travel.segments.last?.duration ?? 0) / 1_000_000_000)
            let departureDateLastSegment = travel.segments.last?.date
            let arrivalDate = departureDateLastSegment?.addingTimeInterval(durationSeconds)
            if showCompleted {
                // select only completed travels
                return (arrivalDate ?? currentDate) <= currentDate
            } else {
                // select only non completed travels
                return (arrivalDate ?? currentDate) > currentDate
            }
        }
    }
    
    private func sortTravels(by sortOption: SortOption) {
        switch sortOption {
        case .departureDate:
            // decreasing departure date
            filteredTravelDetails.sort {
                let date1 = $0.segments.first?.date ?? Date.distantPast
                let date2 = $1.segments.first?.date ?? Date.distantPast
                return date1 > date2
            }
        case .co2Emitted:
            // decreasing co2 emitted
            filteredTravelDetails.sort {
                var co2Emitted1 = 0.0
                for segment in $0.segments {
                    co2Emitted1 += segment.co2Emitted
                }
                var co2Emitted2 = 0.0
                for segment in $1.segments {
                    co2Emitted2 += segment.co2Emitted
                }
                return co2Emitted1 > co2Emitted2
            }
        case .co2CompensationRate:
            // increasing co2 compensated / co2 emitted
            filteredTravelDetails.sort {
                var co2Emitted1 = 0.0
                for segment in $0.segments {
                    co2Emitted1 += segment.co2Emitted
                }
                var co2Emitted2 = 0.0
                for segment in $1.segments {
                    co2Emitted2 += segment.co2Emitted
                }
                let co2Compensated1 = $0.travel.CO2Compensated
                let co2Compensated2 = $1.travel.CO2Compensated
                return co2Compensated1/co2Emitted1 < co2Compensated2/co2Emitted2
            }
        case .price:
            // decreasing price
            filteredTravelDetails.sort {
                var price1 = 0.0
                for segment in $0.segments {
                    price1 += segment.price
                }
                var price2 = 0.0
                for segment in $1.segments {
                    price2 += segment.price
                }
                return price1 > price2
            }
        }
    }
}
