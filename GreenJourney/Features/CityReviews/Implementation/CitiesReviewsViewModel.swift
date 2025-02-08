import Combine
import Foundation
import SwiftData

class CitiesReviewsViewModel: ObservableObject {
    let uuid: UUID = UUID()
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    
    // best cities
    @Published var bestCitiesReviewElements: [CityReviewElement] = []
    @Published var bestCities: [CityCompleterDataset] = []
    
    // searched city
    @Published var searchedCity: CityCompleterDataset = CityCompleterDataset()
    @Published var searchedCityAvailable: Bool = false
    
    // selected city
    @Published var selectedCity: CityCompleterDataset = CityCompleterDataset()
    @Published var selectedCityReviewElement: CityReviewElement?
    
    @Published var userReview: Review?
    @Published var page: Int = 0
    @Published var pageInput: String = "1" // Textfield input
    
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol) {
        self.modelContext = modelContext
        self.serverService = serverService
    }
    
    @MainActor
    func getReviewsForSearchedCity() async {
        do {
            let cityReviewElement = try await serverService.getReviewsForCity(iata: searchedCity.iata, countryCode: searchedCity.countryCode)
            self.selectedCityReviewElement = cityReviewElement
            self.searchedCityAvailable = true
            
            print("Searched city reviews available")
        }catch {
            print("Error getting reviews for searched city")
            return
        }
        print("esco dalla funzione")
    }
    
    @MainActor
    func getBestReviewedCities() async {
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
    
    func getUserReview(userID: Int) {
        guard let selectedCityReviewElement else {return}
        userReview = nil
        for review in selectedCityReviewElement.reviews {
            if review.userID == userID {
                userReview = review
                return
            }
        }
    }
    
    // TODO change - check on iata and country code
    func isReviewable(userID: Int) -> Bool {
        let fetchRequest = FetchDescriptor<Segment>(
            predicate: #Predicate { segment in
                segment.isOutward == true
            },
            sortBy: [
                SortDescriptor(\Segment.travelID),
                SortDescriptor(\Segment.numSegment, order: .reverse)
            ]
        )

        do {
            let segments = try modelContext.fetch(fetchRequest)
            let filteredSegments = Dictionary(grouping: segments, by: \.travelID)
                .compactMapValues { $0.first }
                .values
            for segment in filteredSegments {
                if selectedCity.cityName == segment.destinationCity {
                    if selectedCity.countryName == segment.destinationCountry {
                        return true
                    }
                }
            }
        } catch {
            print("error during segments fetch")
        }
        return false
    }
    
    func getNumPages() -> Int {
        guard let selectedCityReviewElement else { return 0 }
        if selectedCityReviewElement.reviews.count % 10 == 0 {
            return selectedCityReviewElement.reviews.count / 10
        }
        else {
            return (selectedCityReviewElement.reviews.count / 10) + 1
        }
    }
    
    func validatePageInput() {
        if let page = Int(pageInput) {
            if page >= 1 && page <= getNumPages() {
                self.page = page - 1
            }
            pageInput = "\(self.page + 1)" // go back on the previous page
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

