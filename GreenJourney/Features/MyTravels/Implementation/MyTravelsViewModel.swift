import Combine
import Foundation
import FirebaseAuth
import SwiftData

enum SortOption {
    case departureDate
    case price
    case co2Emitted
    case co2CompensationRate
}

class MyTravelsViewModel: ObservableObject {
    private var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    // travels lists
    var travelDetailsList: [TravelDetails] = []
    @Published var filteredTravelDetailsList: [TravelDetails] = []
    @Published var showCompleted = true {
        didSet {
            // already sorted
            // filter according to new filter
            filterTravelDetails()
        }
    }
    @Published var sortOption = SortOption.departureDate {
        didSet {
            // sort according to new sort option
            sortTravels()
            // same filter, but call to show
            filterTravelDetails()
        }
    }
    
    // selected travel
    @Published var selectedTravel: TravelDetails?
    @Published var compensatedPrice: Float64 = 1.0
    @Published var travelReviews: [Review] = []
    
    // upload review
    @Published var reviewText: String = ""
    @Published var localTransportRating: Int = 0
    @Published var greenSpacesRating: Int = 0
    @Published var wasteBinsRating: Int = 0
    
    // modify review
    // can't be modified, it is the id of the review the user is modifying
    @Published var modifiedReviewID: Int = 0
    @Published var modifiedReviewText: String = ""
    @Published var modifiedLocalTransportRating: Int = 0
    @Published var modifiedGreenSpacesRating: Int = 0
    @Published var modifiedWasteBinsRating: Int = 0
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getUserTravels() {        
        do {
            let travels = try modelContext.fetch(FetchDescriptor<Travel>())
            let segments = try modelContext.fetch(FetchDescriptor<Segment>())
            
            let segmentsByTravelID = Dictionary(grouping: segments, by: { $0.travelID })
            travelDetailsList = travels.compactMap { travel in
                if let travelID = travel.travelID {
                    if let travelSegments = segmentsByTravelID[travelID] {
                        return TravelDetails(travel: travel, segments: travelSegments)
                    } else {
                        return TravelDetails(travel: travel, segments: [])
                    }
                }
                return nil
            }
            
            // sort segments for every travel
            sortSegments()
            // sort the new list according to current sort option
            sortTravels()
            // filter according to current filter
            filterTravelDetails()
            
        }catch {
            
            
            
            // TODO: gestire
            
            
            
            print("Error getting user's travels from SwiftData")
        }
    }
    
    private func sortSegments() {
        for td in travelDetailsList {
            td.sortSegments()
        }
    }
    
    // filters travel details list, selecting only past of future travels
    private func filterTravelDetails() {
        let currentDate = Date()
        filteredTravelDetailsList = travelDetailsList.filter { travel in
            let lastSegment = travel.getLastSegment()
            if let lastSegment = lastSegment {
                let durationSeconds = Double(lastSegment.duration) / 1_000_000_000
                let departureDateLastSegment = lastSegment.dateTime
                let arrivalDate = departureDateLastSegment.addingTimeInterval(durationSeconds)
                
                if showCompleted {
                    // select only completed travels
                    return arrivalDate <= currentDate
                } else {
                    // select only non completed travels
                    return arrivalDate > currentDate
                }
            }
            // nothing to sort
            return false
        }
    }
    
    // sort travel details list according to some sort option
    private func sortTravels() {
        switch self.sortOption {
        case .departureDate:
            // decreasing departure date
            travelDetailsList.sort {
                if let firstSegment1 = $0.getFirstSegment() {
                    if let firstSegment2 = $1.getFirstSegment() {
                        let date1 = firstSegment1.dateTime
                        let date2 = firstSegment2.dateTime
                        return date1 > date2
                    }
                }
                return false
            }
        case .co2Emitted:
            // decreasing co2 emitted
            travelDetailsList.sort {
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
            travelDetailsList.sort {
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
            travelDetailsList.sort {
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
    
    func compensateCO2() {
        // compute CO2 compensated
        
        // TODO change
        let co2CompensatedPerEuro = 37.5 // 37.5 kg/€
        let newCo2Compensated = co2CompensatedPerEuro * self.compensatedPrice
        
        // TODO send request
        // update swift data
        
        guard let firebaseUser = Auth.auth().currentUser else {
            print("error retrieving firebase user")
            return
        }
        firebaseUser.getIDToken {[weak self] token, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Failed to fetch token: \(error.localizedDescription)")
                return
            } else if let firebaseToken = token {
                if let selectedTravel = strongSelf.selectedTravel {
                    // JSON encoding and decoding
                    let modifiedTravel = selectedTravel.travel
                    modifiedTravel.CO2Compensated += newCo2Compensated
                    guard let body = try? JSONEncoder().encode(modifiedTravel) else {
                        print("Error encoding user data for PUT")
                        return
                    }
                    let decoder = JSONDecoder()
                    
                    // build URL
                    let baseURL = NetworkHandler.shared.getBaseURL()
                    guard let url = URL(string:"\(baseURL)/travels/user") else {
                        print("Invalid URL used to retrieve travels from DB")
                        return
                    }
                    
                    // build request
                    var request = URLRequest(url: url)
                    request.httpMethod = "PUT"
                    request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    
                    // send request
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
                        .decode(type: Travel.self, decoder: decoder)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                print("Travel update posted successfully.")
                            case .failure(let error):
                                print("Error updating travel data: \(error.localizedDescription)")
                                return
                            }
                        }, receiveValue: { [weak self] travel in
                            guard let strongSelf = self else { return }
                            // save travel in SwiftData
                            strongSelf.updateTravelInSwiftData(updatedTravel: travel)
                            // refresh travels
                            strongSelf.getUserTravels()
                        })
                        .store(in: &strongSelf.cancellables)
                } else {
                    // TODO
                    print("Error")
                }
            } else {
                // TODO
                print("Error")
            }
        }
    }
    
    func updateTravelInSwiftData(updatedTravel: Travel) {
        do {
            let travels = try modelContext.fetch(FetchDescriptor<Travel>())
            
            for travel in travels {
                if travel.travelID == travel.travelID {
                    do {
                        // update values
                        travel.CO2Compensated = updatedTravel.CO2Compensated
                        travel.confirmed = updatedTravel.confirmed
                        try modelContext.save()
                    } catch {
                        print("Error while updating travel in SwiftData")
                        
                        // TODO
                    }
                }
            }
        }catch {
            print("Error while updating user in SwiftData")
            
            // TODO
            
        }
    }
    
    func deleteSelectedTravel() {
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
                if let selectedTravel = strongSelf.selectedTravel {
                    if let travelID = selectedTravel.travel.travelID {
                        // build URL
                        let baseURL = NetworkHandler.shared.getBaseURL()
                        guard let url = URL(string:"\(baseURL)/travels/user/\(travelID)") else {
                            print("Invalid URL used to retrieve travels from DB")
                            return
                        }
                        
                        // build request
                        var request = URLRequest(url: url)
                        request.httpMethod = "DELETE"
                        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
                        
                        // send request
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
                                    print("Travel successfully deleted.")
                                case .failure(let error):
                                    print("Error updating travel data: \(error.localizedDescription)")
                                    return
                                }
                            }, receiveValue: { [weak self] _ in
                                guard let strongSelf = self else { return }
                                // remove from SwiftData
                                strongSelf.deleteTravelFromSwiftData(travelToDelete: strongSelf.selectedTravel)
                                // refresh travels
                                strongSelf.getUserTravels()
                            })
                            .store(in: &strongSelf.cancellables)
                    }
                }
            }
        }
    }
    
    func deleteTravelFromSwiftData(travelToDelete: TravelDetails?) {
        if let travelToDelete = travelToDelete {
            do {
                let travels = try modelContext.fetch(FetchDescriptor<Travel>())
                let segments = try modelContext.fetch(FetchDescriptor<Segment>())
                
                for travel in travels {
                    if travel.travelID == travelToDelete.travel.travelID {
                        modelContext.delete(travel)
                    }
                }
                for segment in segments {
                    if segment.travelID == travelToDelete.travel.travelID {
                        modelContext.delete(segment)
                    }
                }
                
                do {
                    try modelContext.save()
                } catch {
                    print("Error while updating travel in SwiftData")
                    
                    // TODO
                }
            }catch {
                print("Error while updating travel in SwiftData")
                
                // TODO
                
            }
        }
    }
    
    func uploadReview() {
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
            return
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
            // TODO 
            print("Error")
        }
    }
}
