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
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.serverService = ServiceFactory.shared.serverService
    }
    
    func getReviewsForSearchedCity() {
        Task { @MainActor in
            do {
                let cityReviewElement = try await serverService.getReviewsForCity(iata: searchedCity.iata, countryCode: searchedCity.countryCode)
                
                self.searchedCityReviewElement = cityReviewElement
                self.searchedCityAvailable = true
                
                print("Searched city reviews available")
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

