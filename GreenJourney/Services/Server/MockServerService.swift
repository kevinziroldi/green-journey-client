import Foundation

class MockServerService: ServerServiceProtocol {
    func saveUser(firebaseToken: String, firstName: String, lastName: String, firebaseUID: String) async throws {
        // don't save anything
    }
    
    func getUser(firebaseToken: String) async throws -> User {
        // read mock user from json
        guard let path = Bundle.main.path(forResource: "mock_user", ofType: "json") else {
            print("Mock user file not found")
            return User()
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let user = try decoder.decode(User.self, from: data)
            return user
        } catch {
            print(error)
            return User()
        }
    }
    
    func modifyUser(firebaseToken: String, modifiedUser: User) async throws -> User {
        // return the modified user itself
        return modifiedUser
    }
    
    func getRanking(userID: Int) async throws -> RankingResponse {
        // read mock ranking from json
        guard let path = Bundle.main.path(forResource: "mock_ranking", ofType: "json") else {
            print("Mock ranking file not found")
            return RankingResponse()
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let ranking = try decoder.decode(RankingResponse.self, from: data)
            return ranking
        } catch {
            print(error)
            return RankingResponse()
        }
    }
    
    func getReviewsForCity(firebaseToken: String, iata: String, countryCode: String) async throws -> CityReviewElement {
        // read mock review from json
        guard let path = Bundle.main.path(forResource: "mock_review", ofType: "json") else {
            print("Mock review file not found")
            return CityReviewElement()
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let reviews = try decoder.decode(CityReviewElement.self, from: data)
            return reviews
        } catch {
            print(error)
            return CityReviewElement()
        }
    }
    
    func getBestReviewedCities() async throws -> [CityReviewElement] {
        // read mock review from json
        guard let path = Bundle.main.path(forResource: "mock_best_reviewed_cities", ofType: "json") else {
            print("Mock best reviewed cities file not found")
            return []
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let bestCities = try decoder.decode([CityReviewElement].self, from: data)
            return bestCities
        } catch {
            print(error)
            return []
        }
    }
    
    func uploadReview(firebaseToken: String, review: Review) async throws -> Review {
        return review
    }
    
    func modifyReview(firebaseToken: String, modifiedReview: Review) async throws -> Review {
        return modifiedReview
    }
    
    func deleteReview(firebaseToken: String, reviewID: Int) async throws {
        return
    }

    func computeRoutes(departureIata: String, departureCountryCode: String,
                       destinationIata: String, destinationCountryCode: String,
                       date: String, time: String, isOutward: Bool) async throws -> TravelOptionsResponse {
        // read mock review from json
        guard let path = Bundle.main.path(forResource: "mock_travel_options", ofType: "json") else {
            print("Mock travel options file not found")
            return TravelOptionsResponse(options: [])
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let travelOptions = try decoder.decode(TravelOptionsResponse.self, from: data)
            return travelOptions
        } catch {
            print(error)
            return TravelOptionsResponse(options: [])
        }
    }
    
    // TODO
    func saveTravel(firebaseToken: String, travelDetails: TravelDetails) async throws -> TravelDetails {
        // TODO need to add info
        return travelDetails
    }
    
    func getTravels(firebaseToken: String) async throws -> [TravelDetails] {
        // read mock review from json
        guard let path = Bundle.main.path(forResource: "mock_user_travels", ofType: "json") else {
            print("Mock user travel file not found")
            return []
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let travels = try decoder.decode([TravelDetails].self, from: data)
            return travels
        } catch {
            print(error)
            return []
        }
    }
    
    func updateTravel(firebaseToken: String, modifiedTravel: Travel) async throws -> Travel {
        return modifiedTravel
    }
    
    func deleteTravel(firebaseToken: String, travelID: Int) async throws {
        return
    }
}
