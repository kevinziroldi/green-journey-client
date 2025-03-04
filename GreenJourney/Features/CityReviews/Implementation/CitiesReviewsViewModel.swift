import Combine
import Foundation
import SwiftData
import SwiftUI

@MainActor
class CitiesReviewsViewModel: ObservableObject {
    let uuid: UUID = UUID()
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    
    // best cities
    @Published var bestCitiesReviewElements: [CityReviewElement] = []
    @Published var bestCities: [CityCompleterDataset] = []
    
    // searched city
    @Published var searchedCityAvailable: Bool = false
    
    @Published var refreshAvailable: Bool = false
    
    // selected city
    @Published var selectedCity: CityCompleterDataset = CityCompleterDataset()
    @Published var selectedCityReviewElement: CityReviewElement?
    
    @Published var userReview: Review?
    @Published var page: Int = 0
    
    // upload/modify review
    @Published var reviewText: String = ""
    @Published var localTransportRating: Int = 0
    @Published var greenSpacesRating: Int = 0
    @Published var wasteBinsRating: Int = 0
        
    @Published var errorMessage: String? = nil
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol) {
        self.modelContext = modelContext
        self.serverService = serverService
    }
    
    func getReviewsForSearchedCity() async {
        do {
            let cityReviewElement = try await serverService.getReviewsForCity(iata: selectedCity.iata, countryCode: selectedCity.countryCode)
            self.selectedCityReviewElement = cityReviewElement
            self.searchedCityAvailable = true
            
            print("Searched city reviews available")
        }catch {
            print("Error getting reviews for searched city")
            return
        }
    }
    
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
    
    func isReviewable(userID: Int) -> Bool {
        return hasVisited(city: selectedCity)
    }
    
    func hasVisited(city: CityCompleterDataset) -> Bool {
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
            
            // cityName + countryName uniquely identifies a city in the dataset
            for segment in filteredSegments {
                if city.cityName == segment.destinationCity {
                    if city.countryName == segment.destinationCountry {
                        return true
                    }
                }
            }
        } catch {
            print("Error during segments fetch")
        }
        
        return false
    }
        
    func uploadReview() async {
        let users: [User]
        do {
            users = try modelContext.fetch(FetchDescriptor<User>())
        } catch {
            print("No user found")
            self.errorMessage = "An error occurred while saving the review"
            return
        }
        guard let user = users.first else {
            print("No user found")
            self.errorMessage = "An error occurred while saving the review"
            return
        }
        guard let userID = users.first?.userID else {
            print("No user found")
            self.errorMessage = "An error occurred while saving the review"
            return
        }
        
        let review = Review(
            reviewID: nil,
            cityID: nil,
            userID: userID,
            reviewText: self.reviewText,
            localTransportRating: self.localTransportRating,
            greenSpacesRating: self.greenSpacesRating,
            wasteBinsRating: self.wasteBinsRating,
            cityIata: selectedCity.iata,
            countryCode: selectedCity.countryCode,
            firstName: user.firstName,
            lastName: user.lastName,
            scoreShortDistance: user.scoreShortDistance,
            scoreLongDistance: user.scoreLongDistance,
            badges: user.badges
        )
        
        do {
            let userReview = try await serverService.uploadReview(review: review)
            self.userReview = userReview
            self.selectedCityReviewElement?.addUserReview(userReview: userReview)
        } catch {
            self.errorMessage = "An error occurred while saving the review"
            return
        }
    }
    
    func modifyReview() async {
        guard let userReview = self.userReview else {
            self.errorMessage = "Error while modifying the review"
            return
        }
        
        let modifiedReview = Review(
            reviewID: userReview.reviewID,
            cityID: userReview.cityID,
            userID: userReview.userID,
            reviewText: self.reviewText,
            localTransportRating: self.localTransportRating,
            greenSpacesRating: self.greenSpacesRating,
            wasteBinsRating: self.wasteBinsRating,
            cityIata: userReview.cityIata,
            countryCode: userReview.countryCode,
            firstName: userReview.firstName,
            lastName: userReview.lastName,
            scoreShortDistance: userReview.scoreShortDistance,
            scoreLongDistance: userReview.scoreLongDistance,
            badges: userReview.badges
        )
        
        do {
            let modifiedReview = try await serverService.modifyReview(modifiedReview: modifiedReview)
            self.selectedCityReviewElement?.modifyUserReview(oldReview: userReview, newReview: modifiedReview)
            self.userReview = modifiedReview
        } catch {
            self.errorMessage = "Error while modifying the review"
            return
        }
    }
    
    func deleteReview() async {
        guard let userReview = self.userReview else {
            self.errorMessage = "Error while deleting the review"
            return
        }
        
        guard let reviewID = userReview.reviewID else {
            self.errorMessage = "Error while deleting the review"
            return
        }
        
        do {
            try await serverService.deleteReview(reviewID: reviewID)
            self.userReview = nil
        } catch {
            self.errorMessage = "Error while deleting the review"
            return
        }
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
    
    func getDestinationCity(city: String, country: String) {
        do {
            var fetchDescriptor = FetchDescriptor<CityCompleterDataset>(
                predicate: #Predicate<CityCompleterDataset> {
                    $0.countryName == country &&
                    $0.cityName == city }
            )
            fetchDescriptor.fetchLimit = 1
            if let destinationCity = try modelContext.fetch(fetchDescriptor).first {
                selectedCity = destinationCity
            }
        }catch {
            print("Error retrieving destination city from SwiftData")
        }
    }
    
}

extension CitiesReviewsViewModel: Hashable {
    nonisolated static func == (lhs: CitiesReviewsViewModel, rhs: CitiesReviewsViewModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

