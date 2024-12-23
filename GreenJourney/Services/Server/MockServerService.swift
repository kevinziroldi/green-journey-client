import Foundation

// TODO realize mock
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
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
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
            let ranking = try JSONDecoder().decode(RankingResponse.self, from: data)
            return ranking
        } catch {
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
            let reviews = try JSONDecoder().decode(CityReviewElement.self, from: data)
            return reviews
        } catch {
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
            let bestCities = try JSONDecoder().decode([CityReviewElement].self, from: data)
            return bestCities
        } catch {
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
        
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/travels/search?iata_departure=\(departureIata)&country_code_departure=\(departureCountryCode)&iata_destination=\(destinationIata)&country_code_destination=\(destinationCountryCode)&date=\(date)&time=\(time)&is_outward=\(isOutward)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // build decoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
            
        // decode response
        do {
            let travelOptions = try decoder.decode(TravelOptionsResponse.self, from: data)
            return travelOptions
        } catch {
            print("Failed to decode review: \(error.localizedDescription)")
            throw NSError(domain: "UploadReviewError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode review."])
        }
    }
    
    // TODO
    func saveTravel(firebaseToken: String, travelDetails: TravelDetails) async throws -> TravelDetails {
        // TODO need to add info
        return travelDetails
    }
    
    func getTravels(firebaseToken: String) async throws -> [TravelDetails] {
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/travels/user") else {
            print("Invalid URL.")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        
        // build JSON decoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
            
        // decode response
        do {
            let travelDetailsList = try decoder.decode([TravelDetails].self, from: data)
            return travelDetailsList
        } catch {
            print("Failed to decode travels: \(error.localizedDescription)")
            throw NSError(domain: "GetTravelsError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode travels."])
        }
    }
    
    func updateTravel(firebaseToken: String, modifiedTravel: Travel) async throws -> Travel {
        return modifiedTravel
    }
    
    func deleteTravel(firebaseToken: String, travelID: Int) async throws {
        return
    }
}
