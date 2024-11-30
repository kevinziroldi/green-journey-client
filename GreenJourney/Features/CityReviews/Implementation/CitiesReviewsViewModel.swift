import Combine
import FirebaseAuth
import Foundation
import SwiftData

class CitiesReviewsViewModel: ObservableObject {
    private var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    // best cities
    @Published var bestCitiesReviewElements: [CityReviewElement] = []
    @Published var bestCities: [CityCompleterDataset] = []
    
    // searched city
    @Published var searchedCity: CityCompleterDataset = CityCompleterDataset()
    @Published var searchedCityReviewElement: CityReviewElement?
    
    // selected city
    @Published var selectedCity: CityCompleterDataset?
    @Published var selectedCityReviewElement: CityReviewElement?
    
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getReviewsForSearchedCity() {
        guard let firebaseUser = Auth.auth().currentUser else {
            print("error retrieving firebase user")
            return
        }
        firebaseUser.getIDToken { token, error in
            if let error = error {
                print("Failed to fetch token: \(error.localizedDescription)")
                return
            } else if let firebaseToken = token {
                // build URL
                let baseURL = NetworkManager.shared.getBaseURL()
                guard let url = URL(string:"\(baseURL)/reviews?city_iata=\(self.searchedCity.iata)&country_code=\(self.searchedCity.countryCode)") else {
                    print("Invalid URL used to retrieve user from DB")
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                URLSession.shared.dataTaskPublisher(for: request)
                    .retry(2)
                    .tryMap {
                        result -> Data in
                        guard let httpResponse = result.response as? HTTPURLResponse,
                              (200...299).contains(httpResponse.statusCode) else {
                            throw URLError(.badServerResponse)
                        }
                        return result.data
                    }
                    .decode(type: CityReviewElement.self, decoder: decoder)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: {
                        completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print("Error fetching user: \(error.localizedDescription)")
                        }
                    }, receiveValue: { cityReviewElement in
                        self.searchedCityReviewElement = cityReviewElement
                    })
                    .store(in: &self.cancellables)
            }
        }
    }
        
    func getBestReviewedCities() {
        let baseURL = NetworkManager.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/reviews/best") else {
            print("Invalid URL used to retrieve user from DB")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // no authorization needed
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        URLSession.shared.dataTaskPublisher(for: request)
            .retry(2)
            .tryMap {
                result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: [CityReviewElement].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching user: \(error.localizedDescription)")
                }
            }, receiveValue: { bestCities in
                // remove old elements
                self.bestCitiesReviewElements = []
                self.bestCities = []
                
                // add new elements
                for bestReviewCity in bestCities {
                    if let cityIata = bestReviewCity.reviews.first?.cityIata {
                        if let countryCode = bestReviewCity.reviews.first?.countryCode {
                            let descriptor = FetchDescriptor<CityCompleterDataset>(
                                predicate: #Predicate { city in
                                    city.iata == cityIata && city.countryCode == countryCode
                                }
                            )
                            do {
                                if let bestCity = try self.modelContext.fetch(descriptor).first {
                                    self.bestCitiesReviewElements.append(bestReviewCity)
                                    self.bestCities.append(bestCity)
                                }
                            }catch {
                                
                                print("Error interacting with SwiftData")
                                
                                // TODO
                                
                            }
                        }
                    }
                }
                
                
            })
            .store(in: &cancellables)
    }
}
