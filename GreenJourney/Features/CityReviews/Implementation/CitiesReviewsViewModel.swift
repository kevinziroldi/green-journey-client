import Combine
import FirebaseAuth
import Foundation
import SwiftData

class CitiesReviewsViewModel: ObservableObject {
    let uuid: UUID = UUID()
    
    private var modelContext: ModelContext
    
    // best cities
    @Published var bestCitiesReviewElements: [CityReviewElement] = []
    @Published var bestCities: [CityCompleterDataset] = []
    
    // searched city
    @Published var searchedCity: CityCompleterDataset = CityCompleterDataset()
    @Published var searchedCityReviewElement: CityReviewElement?
    @Published var searchedCityAvailable: Bool = false
    
    // selected city
    @Published var selectedCity: CityCompleterDataset?
    @Published var selectedCityReviewElement: CityReviewElement?
    
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // TODO mock or not mock
        self.serverService = ServerService()
        self.firebaseAuthService = FirebaseAuthService()
    }
    
    func getReviewsForSearchedCity() {
        Task { @MainActor in
            guard let firebaseUser = Auth.auth().currentUser else {
                print("Error retrieving firebase user")
                return
            }
            
            do {
                let firebaseToken = try await firebaseAuthService.getFirebaseToken(firebaseUser: firebaseUser)
                let cityReviewElement = try await serverService.getReviewsForCity(firebaseToken: firebaseToken, iata: searchedCity.iata, countryCode: searchedCity.countryCode)
                
                self.searchedCityReviewElement = cityReviewElement
                self.searchedCityAvailable = true
            }catch {
                print("Error getting reviews for searched city")
                return
            }
        }
    }
    
    func getBestReviewedCities() {
        Task { @MainActor in
            do {
                let bestReviewedCities = try await serverService.getBestReviewedCities()
                
                // remove old elements
                self.bestCitiesReviewElements = []
                self.bestCities = []
                
                // add new elements
                for bestReviewCity in bestReviewedCities {
                    if let cityIata = bestReviewCity.reviews.first?.cityIata {
                        if let countryCode = bestReviewCity.reviews.first?.countryCode {
                            let descriptor = FetchDescriptor<CityCompleterDataset>(
                                predicate: #Predicate { city in
                                    city.iata == cityIata && city.countryCode == countryCode
                                }
                            )
                            do {
                                if let bestCity = try
                                    self.modelContext.fetch(descriptor).first {
                                    self.bestCitiesReviewElements.append(bestReviewCity)
                                    self.bestCities.append(bestCity)
                                }
                            }catch {
                                // just skip one city
                                print("Error interacting with SwiftData")
                            }
                        }
                    }
                }
            }catch {
                print("Error getting best reviewed cities")
                return
            }
        }
    }
}

extension CitiesReviewsViewModel: Hashable {
    static func == (lhs: CitiesReviewsViewModel, rhs: CitiesReviewsViewModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

