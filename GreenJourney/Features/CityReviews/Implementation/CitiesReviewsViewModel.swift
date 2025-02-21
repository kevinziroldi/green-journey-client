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
    //@Published var searchedCity: CityCompleterDataset = CityCompleterDataset()
    @Published var searchedCityAvailable: Bool = false
    
    // selected city
    @Published var selectedCity: CityCompleterDataset = CityCompleterDataset()
    @Published var selectedCityReviewElement: CityReviewElement?
    
    @Published var userReview: Review?
    @Published var page: Int = 0
    // Textfield input
    @Published var pageInput: Int = 1
    
    // upload review
    @Published var reviewText: String = ""
    @Published var localTransportRating: Int = 0
    @Published var greenSpacesRating: Int = 0
    @Published var wasteBinsRating: Int = 0
    
    // modify review
    @Published var modifiedReviewText: String = ""
    @Published var modifiedLocalTransportRating: Int = 0
    @Published var modifiedGreenSpacesRating: Int = 0
    @Published var modifiedWasteBinsRating: Int = 0
    
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
                if selectedCity.cityName == segment.destinationCity {
                    if selectedCity.countryName == segment.destinationCountry {
                        return true
                    }
                }
            }
        } catch {
            print("Error during segments fetch")
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
        if pageInput >= 1 && pageInput <= getNumPages() {
            self.page = pageInput - 1
        }
        self.pageInput = self.page + 1 // go back on the previous page
    }
    
    func binding(for value: Binding<Int>) -> Binding<String> {
        Binding<String>(
            get: {
                return String(value.wrappedValue)
            },
            set: { newValue in
                if let intValue = Int(newValue) {
                    value.wrappedValue = intValue
                } else {
                    value.wrappedValue = 0
                }
            }
        )
    }
    
    /*
    func uploadReview() {
        
        let review = Review(reviewID: nil, cityID: destinationSegment.destinationID, userID: selectedTravel.travel.userID, reviewText: strongSelf.reviewText, localTransportRating: strongSelf.localTransportRating, greenSpacesRating: strongSelf.greenSpacesRating, wasteBinsRating: strongSelf.wasteBinsRating)
            
        
        if let selectedTravel = selectedTravel {
            if let destinationSegment = selectedTravel.getLastSegment() {
                // make POST request
                if let firebaseUser = Auth.auth().currentUser {
                    firebaseUser.getIDToken { [weak self] token, error in
                        guard let strongSelf = self else { return }
                        if let error = error {
                            print("error getting firebase token: \(error.localizedDescription)")
                            return
                        } else if let firebaseToken = token {
                            // create review
                            let review = Review(reviewID: nil, cityID: destinationSegment.destinationID, userID: selectedTravel.travel.userID, reviewText: strongSelf.reviewText, localTransportRating: strongSelf.localTransportRating, greenSpacesRating: strongSelf.greenSpacesRating, wasteBinsRating: strongSelf.wasteBinsRating)
                            
                            // JSON encoding
                            let encoder = JSONEncoder()
                            let decoder = JSONDecoder()
                            guard let body = try? encoder.encode(review) else {
                                print("Error encoding review data")
                                return
                            }
                            
                            // build URL
                            let baseURL = NetworkHandler.shared.getBaseURL()
                            guard let url = URL(string: "\(baseURL)/reviews") else {
                                print("Invalid URL for posting user data to DB")
                                return
                            }
                            
                            // create POST request
                            var request = URLRequest(url: url)
                            request.httpMethod = "POST"
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
                            request.httpBody = body
                            
                            URLSession.shared.dataTaskPublisher(for: request)
                                .retry(2)
                                .tryMap {
                                    result -> Data in
                                    // check status of response
                                    guard let httpResponse = result.response as? HTTPURLResponse,
                                          (200...299).contains(httpResponse.statusCode) else {
                                        throw URLError(.badServerResponse)
                                    }
                                    return result.data
                                }
                                .receive(on: DispatchQueue.main)
                                .decode(type: Review.self, decoder: decoder)
                                .sink(receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        print("Travel data posted successfully.")
                                    case .failure(let error):
                                        print("Error posting travel data: \(error.localizedDescription)")
                                        return
                                    }
                                }, receiveValue: { [weak self] review in
                                    guard let strongSelf = self else { return }
                                    strongSelf.travelReviews.append(review)
                                })
                                .store(in: &strongSelf.cancellables)
                        }
                    }
                }else {
                    // TODO
                    print("Firebase error")
                    return
                }
            }else {
                // TODO
                print("Error")
                return
            }
        }else {
            // TODO
            print("Error")
            return
        }
    }
    
    func modifyReview() {
        if let firebaseUser = Auth.auth().currentUser {
            firebaseUser.getIDToken { [weak self] token, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("error getting firebase token: \(error.localizedDescription)")
                    return
                } else if let firebaseToken = token {
                    // get review
                    var reviewToModify: Review? = nil
                    for review in strongSelf.travelReviews {
                        if review.reviewID == strongSelf.modifiedReviewID {
                            reviewToModify = review
                        }
                    }
                    if let reviewToModify = reviewToModify {
                        if let reviewID  = reviewToModify.reviewID {
                            // create modified review
                            let modifiedReview = Review(reviewID: reviewToModify.reviewID, cityID: reviewToModify.cityID, userID: reviewToModify.userID, reviewText: strongSelf.modifiedReviewText, localTransportRating: strongSelf.modifiedLocalTransportRating, greenSpacesRating: strongSelf.modifiedGreenSpacesRating, wasteBinsRating: strongSelf.modifiedWasteBinsRating)
                            
                            // JSON encoding
                            let encoder = JSONEncoder()
                            let decoder = JSONDecoder()
                            guard let body = try? encoder.encode(modifiedReview) else {
                                print("Error encoding user data for PUT")
                                return
                            }
                            
                            // create URL
                            let baseURL = NetworkHandler.shared.getBaseURL()
                            guard let url = URL(string: "\(baseURL)/reviews/\(reviewID)") else {
                                print("Invalid URL for posting user data to DB")
                                return
                            }
                            // create PUT request
                            var request = URLRequest(url: url)
                            request.httpMethod = "PUT"
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
                            request.httpBody = body
                            
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
                                .decode(type: Review.self, decoder: decoder)
                                .receive(on: DispatchQueue.main)
                                .sink(receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        print("User data posted successfully.")
                                    case .failure(let error):
                                        print("Error posting user data: \(error.localizedDescription)")
                                    }
                                }, receiveValue: { [weak self] updatedReview in
                                    guard let strongSelf = self else { return }
                                    // remove old review and add new one
                                    var travelReviewsUpdated: [Review] = []
                                    
                                    for review in strongSelf.travelReviews {
                                        if review.reviewID != reviewID {
                                            travelReviewsUpdated.append(review)
                                        } else {
                                            travelReviewsUpdated.append(updatedReview)
                                        }
                                    }
                                    
                                    strongSelf.travelReviews = travelReviewsUpdated
                                })
                                .store(in: &strongSelf.cancellables)
                        }
                    }else {
                        print("Review to modify not found")
                        return
                    }
                }
            }
        }else {
            print("Firebase error")
        }
    }
    
    func deleteReview(reviewID: Int) {
        if let firebaseUser = Auth.auth().currentUser {
            firebaseUser.getIDToken { [weak self] token, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("error getting firebase token: \(error.localizedDescription)")
                    return
                } else if let firebaseToken = token {
                    // build URL
                    let baseURL = NetworkHandler.shared.getBaseURL()
                    guard let url = URL(string:"\(baseURL)/reviews/\(reviewID)") else {
                        print("Invalid URL used to retrieve travels from DB")
                        return
                    }
                    
                    // build request
                    var request = URLRequest(url: url)
                    request.httpMethod = "DELETE"
                    request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
                    
                    // send DELETE request
                    URLSession.shared.dataTaskPublisher(for: request)
                        .retry(2)
                        .tryMap {
                            result -> Data in
                            // check status of response
                            guard let httpResponse = result.response as? HTTPURLResponse,
                                  (200...299).contains(httpResponse.statusCode) else {
                                throw URLError(.badServerResponse)
                            }
                            return result.data
                        }
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                print("Review successfully deleted.")
                            case .failure(let error):
                                print("Error deleting review: \(error.localizedDescription)")
                                return
                            }
                        }, receiveValue: { [weak self] _ in
                            guard let strongSelf = self else { return }
                            // remove from travelReviews
                            var travelReviewsUpdated: [Review] = []
                            for travelReview in strongSelf.travelReviews {
                                if travelReview.reviewID != reviewID {
                                    travelReviewsUpdated.append(travelReview)
                                }
                            }
                            strongSelf.travelReviews = travelReviewsUpdated
                        })
                        .store(in: &strongSelf.cancellables)
                }
            }
        }else {
            print("Firebase error")
        }
    }
     */
}

extension CitiesReviewsViewModel: Hashable {
    nonisolated static func == (lhs: CitiesReviewsViewModel, rhs: CitiesReviewsViewModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

