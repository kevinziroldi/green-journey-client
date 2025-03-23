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
    @Published var bestCitiesLoaded: Bool = false
    
    //reviewable cities
    @Published var reviewableCities: [CityCompleterDataset] = []
    
    // searched city
    @Published var searchedCityAvailable: Bool = false
    @Published var refreshAvailable: Bool = false
    
    // selected city
    @Published var selectedCity: CityCompleterDataset = CityCompleterDataset()
    @Published var selectedCityReviewElement: CityReviewElement?
    @Published var userReview: Review?
    
    // current reviews shown in AllReviews
    @Published var currentReviews: [Review] = []
    @Published var hasPrevious: Bool = false
    @Published var hasNext: Bool = false
    
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
    
    func getSelectedCityReviewElement(reload: Bool) async {
        do {
            let cityReviewElement = try await serverService.getFirstReviewsForCity(iata: selectedCity.iata, countryCode: selectedCity.countryCode)
            self.selectedCityReviewElement = cityReviewElement
            self.currentReviews = cityReviewElement.reviews
            self.hasPrevious = cityReviewElement.hasPrevious
            self.hasNext = cityReviewElement.hasNext
            
            if !reload {
                self.searchedCityAvailable = true
                print("Searched city reviews available")
            }
        }catch {
            print("Error getting reviews for searched city")
            return
        }
    }
    
    func getFirstReviewsForSearchedCity() async {
        do {
            let cityReviewElement = try await serverService.getFirstReviewsForCity(iata: selectedCity.iata, countryCode: selectedCity.countryCode)
            
            self.currentReviews = cityReviewElement.reviews
            self.hasPrevious = cityReviewElement.hasPrevious
            self.hasNext = cityReviewElement.hasNext
        }catch {
            print("Error getting reviews for searched city")
            return
        }
    }
    
    func getLastReviewsForSearchedCity() async {
        do {
            let cityReviewElement = try await serverService.getLastReviewsForCity(iata: selectedCity.iata, countryCode: selectedCity.countryCode)
           
            self.currentReviews = cityReviewElement.reviews
            self.hasPrevious = cityReviewElement.hasPrevious
            self.hasNext = cityReviewElement.hasNext
        }catch {
            print("Error getting reviews for searched city")
            return
        }
    }
    
    func getPreviousReviewsForSearchedCity() async {
        // previous = newest
        if !self.hasPrevious {
            print("No previous reviews")
            return
        }
        
        // find biggest review id of the list
        guard let newestReviewID = currentReviews.first?.reviewID else {
            print("No review present")
            return
        }
        
        // server call
        do {
            // previous, direction = false
            let cityReviewElement = try await serverService.getReviewsForCity(iata: selectedCity.iata, countryCode: selectedCity.countryCode, reviewID: newestReviewID, direction: false)
            
            //self.selectedCityReviewElement = cityReviewElement
            self.currentReviews = cityReviewElement.reviews
            self.hasPrevious = cityReviewElement.hasPrevious
            self.hasNext = cityReviewElement.hasNext
        }catch {
            print("Error getting reviews for searched city")
            return
        }
    }
    
    func getNextReviewsForSearchedCity() async {
        // next = oldest
        if !self.hasNext {
            print("No next reviews")
            return
        }
        
        // find smallest review id of the list
        guard let oldestReviewID = currentReviews.last?.reviewID else {
            print("No review present")
            return
        }
        
        // server call
        do {
            // previous, direction = false
            let cityReviewElement = try await serverService.getReviewsForCity(iata: selectedCity.iata, countryCode: selectedCity.countryCode, reviewID: oldestReviewID, direction: true)
            
            //self.selectedCityReviewElement = cityReviewElement
            self.currentReviews = cityReviewElement.reviews
            self.hasPrevious = cityReviewElement.hasPrevious
            self.hasNext = cityReviewElement.hasNext
        }catch {
            print("Error getting reviews for searched city")
            return
        }
    }
    
    func getBestReviewedCities() async {
        do {
            // remove old elements
            self.bestCitiesReviewElements = []
            self.bestCities = []
            self.bestCitiesLoaded = false
            let bestReviewedCities = try await serverService.getBestReviewedCities()
            self.bestCitiesLoaded = true
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
        guard let selectedCityReviewElement else { return }
        userReview = nil
        for review in selectedCityReviewElement.reviews {
            if review.userID == userID {
                userReview = review
                return
            }
        }
    }
    
    func isReviewable() -> Bool {
        return hasVisited(city: selectedCity)
    }
    
    func hasVisited(city: CityCompleterDataset) -> Bool {
        let fetchTravels = FetchDescriptor<Travel> (
            predicate: #Predicate { travel in
                travel.confirmed
            }
        )
        let fetchSegments = FetchDescriptor<Segment>(
            predicate: #Predicate { segment in
                segment.isOutward == true
            },
            sortBy: [
                SortDescriptor(\Segment.travelID),
                SortDescriptor(\Segment.numSegment, order: .reverse)
            ]
        )
        do {
            let travels = try modelContext.fetch(fetchTravels).map( \.travelID )
            let segments = try modelContext.fetch(fetchSegments).filter { travels.contains($0.travelID) }
            
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
    
    func getReviewableCities() async {
        do{
            var citiesToReview: [CityCompleterDataset] = []
            let travels = try modelContext.fetch(FetchDescriptor<Travel>(predicate: #Predicate { travel in
                travel.confirmed && travel.userReview == nil
            })).map( \.travelID )
            let segments = try modelContext.fetch(FetchDescriptor<Segment>(
                predicate: #Predicate { segment in
                    segment.isOutward == true
                },
                sortBy: [
                    SortDescriptor(\Segment.travelID),
                    SortDescriptor(\Segment.numSegment, order: .reverse)
                ]
            )).filter { travels.contains($0.travelID) }
            
            let filteredSegments = Dictionary(grouping: segments, by: \.travelID)
                .compactMapValues { $0.first }
                .values
            for segment in filteredSegments {
                guard let city = try modelContext.fetch(FetchDescriptor<CityCompleterDataset>(predicate: #Predicate { city in
                    city.cityName == segment.destinationCity && city.countryName == segment.destinationCountry
                })).first else {
                    continue
                }
                if !citiesToReview.contains(city) {
                    citiesToReview.append(city)
                }
            }
            self.reviewableCities = citiesToReview.sorted { $0.cityName < $1.cityName }
        }
        catch {
            print("error retrieving user travels from SwiftData")
        }
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
            dateTime: Date.now,
            cityIata: selectedCity.iata,
            countryCode: selectedCity.countryCode,
            firstName: user.firstName,
            lastName: user.lastName
        )
        
        do {
            let userReview = try await serverService.uploadReview(review: review)
            self.userReview = userReview
            await getSelectedCityReviewElement(reload: true)
            uploadReviewToSwiftData(userReview: userReview)
        } catch {
            self.errorMessage = "An error occurred while saving the review"
            return
        }
    }
    
    func uploadReviewToSwiftData(userReview: Review) {
        do {
            let travels = try modelContext.fetch(FetchDescriptor<Travel>(predicate: #Predicate { travel in
                travel.confirmed
            }))
            let travelsID = travels.map( \.travelID )
            let segments = try modelContext.fetch(FetchDescriptor<Segment>(
                predicate: #Predicate { segment in
                     segment.isOutward == true
                },
                sortBy: [
                    SortDescriptor(\Segment.travelID),
                    SortDescriptor(\Segment.numSegment, order: .reverse)
                ]
            )).filter { travelsID.contains($0.travelID) }
            
            let filteredSegments = Dictionary(grouping: segments, by: \.travelID)
                .compactMapValues { $0.first }
                .values
            var travelsToChange: [Int] = []
            for segment in filteredSegments {
                if segment.destinationCity == selectedCity.cityName && segment.destinationCountry == selectedCity.countryName {
                    travelsToChange.append(segment.travelID)
                }
            }
            for travel in travels {
                if travelsToChange.contains(travel.travelID ?? -1) {
                    travel.userReview = userReview
                    try modelContext.save()
                }
            }
        }
        catch {
            print("error uploading the review in SwiftData")
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
            dateTime: userReview.dateTime,
            cityIata: userReview.cityIata,
            countryCode: userReview.countryCode,
            firstName: userReview.firstName,
            lastName: userReview.lastName
        )
        
        do {
            let modifiedReview = try await serverService.modifyReview(modifiedReview: modifiedReview)
            self.userReview = modifiedReview
            await getSelectedCityReviewElement(reload: true)
            modifyReviewInSwiftData(userReview: modifiedReview)
        } catch {
            self.errorMessage = "Error while modifying the review"
            return
        }
    }
    
    func modifyReviewInSwiftData(userReview: Review) {
        do {
            let travels = try modelContext.fetch(FetchDescriptor<Travel>(predicate: #Predicate { travel in
                travel.confirmed
            }))
            let travelsID = travels.map( \.travelID )
            let segments = try modelContext.fetch(FetchDescriptor<Segment>(
                predicate: #Predicate { segment in
                     segment.isOutward == true
                },
                sortBy: [
                    SortDescriptor(\Segment.travelID),
                    SortDescriptor(\Segment.numSegment, order: .reverse)
                ]
            )).filter { travelsID.contains($0.travelID) }
            
            let filteredSegments = Dictionary(grouping: segments, by: \.travelID)
                .compactMapValues { $0.first }
                .values
            var travelsToChange: [Int] = []
            for segment in filteredSegments {
                if segment.destinationCity == selectedCity.cityName && segment.destinationCountry == selectedCity.countryName {
                    travelsToChange.append(segment.travelID)
                }
            }
            for travel in travels {
                if travelsToChange.contains(travel.travelID ?? -1) {
                    travel.userReview = userReview
                }
            }
            try modelContext.save()
        }
        catch {
            print("Error while modifying the review in SwiftData")
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
            await getSelectedCityReviewElement(reload: true)
            deleteReviewFromSwiftData(userReviewID: reviewID)
            self.userReview = nil
        } catch {
            self.errorMessage = "Error while deleting the review"
            return
        }
    }
     
    func deleteReviewFromSwiftData(userReviewID: Int) {
        do {
            let travels = try modelContext.fetch(FetchDescriptor<Travel>(predicate: #Predicate { travel in
                travel.confirmed
            }))
            let travelsID = travels.map( \.travelID )
            let segments = try modelContext.fetch(FetchDescriptor<Segment>(
                predicate: #Predicate { segment in
                     segment.isOutward == true
                },
                sortBy: [
                    SortDescriptor(\Segment.travelID),
                    SortDescriptor(\Segment.numSegment, order: .reverse)
                ]
            )).filter { travelsID.contains($0.travelID) }
            
            let filteredSegments = Dictionary(grouping: segments, by: \.travelID)
                .compactMapValues { $0.first }
                .values
            var travelsToChange: [Int] = []
            for segment in filteredSegments {
                if segment.destinationCity == selectedCity.cityName && segment.destinationCountry == selectedCity.countryName {
                    travelsToChange.append(segment.travelID)
                }
            }
            for travel in travels {
                if travelsToChange.contains(travel.travelID ?? -1) {
                    travel.userReview = nil
                }
            }
            try modelContext.save()
        }
        catch{
            print("Error deleting the review from SwiftData")
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

