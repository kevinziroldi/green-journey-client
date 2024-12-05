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
        firebaseUser.getIDToken { [weak self] token, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Failed to fetch token: \(error.localizedDescription)")
                return
            } else if let firebaseToken = token {
                // build URL
                let baseURL = NetworkManager.shared.getBaseURL()
                guard let url = URL(string:"\(baseURL)/reviews?city_iata=\(strongSelf.searchedCity.iata)&country_code=\(strongSelf.searchedCity.countryCode)") else {
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
                    }, receiveValue: {[weak self] cityReviewElement in
                        guard let strongSelf = self else { return }
                        strongSelf.searchedCityReviewElement = cityReviewElement
                    })
                    .store(in: &strongSelf.cancellables)
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
            }, receiveValue: { [weak self] bestCities in
                guard let strongSelf = self else { return }
                // remove old elements
                strongSelf.bestCitiesReviewElements = []
                strongSelf.bestCities = []
                
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
                                if let bestCity = try strongSelf.modelContext.fetch(descriptor).first {
                                    strongSelf.bestCitiesReviewElements.append(bestReviewCity)
                                    strongSelf.bestCities.append(bestCity)
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
    
    func resetParameters() {
        self.searchedCity = CityCompleterDataset()
    }
}
