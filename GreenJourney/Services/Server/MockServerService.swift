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
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/reviews?city_iata=\(iata)&country_code=\(countryCode)") else {
            print("Invalid URL.")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        
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
            let reviews = try decoder.decode(CityReviewElement.self, from: data)
            return reviews
        } catch {
            print("Failed to decode reviews: \(error.localizedDescription)")
            throw NSError(domain: "GetReviewsError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode reviews."])
        }
    }
    
    func getBestReviewedCities() async throws -> [CityReviewElement] {
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/reviews/best") else {
            print("Invalid URL used to retrieve user from DB")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // no authorization needed
        
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
            let reviews = try decoder.decode([CityReviewElement].self, from: data)
            return reviews
        } catch {
            print("Failed to decode city review elements: \(error.localizedDescription)")
            throw NSError(domain: "GetReviewsError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode city review elements."])
        }
    }
    
    func uploadReview(firebaseToken: String, review: Review) async throws -> Review {
        // JSON encoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        guard let body = try? encoder.encode(review) else {
            print("Error encoding review data")
            throw NSError(domain: "GetReviewsError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to encode review."])
        }
        
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string: "\(baseURL)/reviews") else {
            print("Invalid URL for posting user data to DB")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        // perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
            
        // decode response
        do {
            let review = try decoder.decode(Review.self, from: data)
            return review
        } catch {
            print("Failed to decode review: \(error.localizedDescription)")
            throw NSError(domain: "UploadReviewError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode review."])
        }
    }
    
    func modifyReview(firebaseToken: String, modifiedReview: Review) async throws -> Review {
        // JSON encoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        guard let body = try? encoder.encode(modifiedReview) else {
            print("Error encoding review data for PUT")
            throw NSError(domain: "ModifyReviewError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to encode review."])
        }
        
        // extract reviewID
        guard let reviewID = modifiedReview.reviewID else {
            print("Review ID missing")
            throw NSError(domain: "ModifyReviewError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Review ID missing."])
        }
        
        // create request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string: "\(baseURL)/reviews/\(reviewID)") else {
            print("Invalid URL for posting user data to DB")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        // perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
            
        // decode response
        do {
            let review = try decoder.decode(Review.self, from: data)
            return review
        } catch {
            print("Failed to decode review: \(error.localizedDescription)")
            throw NSError(domain: "UploadReviewError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode review."])
        }
    }
    
    func deleteReview(firebaseToken: String, reviewID: Int) async throws {
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/reviews/\(reviewID)") else {
            print("Invalid URL used to retrieve travels from DB")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        
        // perform request
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
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
    
    func saveTravel(firebaseToken: String, travelDetails: TravelDetails) async throws -> TravelDetails {
        // JSON encoding
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let body = try? encoder.encode(travelDetails) else {
            print("Error encoding travel data")
            throw NSError(domain: "SaveTravelError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to encode travel details."])
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string: "\(baseURL)/travels/user") else {
            print("Invalid URL for posting user data to DB")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        // perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
            
        // decode response
        do {
            let travelDetails = try decoder.decode(TravelDetails.self, from: data)
            return travelDetails
        } catch {
            print("Failed to decode review: \(error.localizedDescription)")
            throw NSError(domain: "UploadReviewError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode review."])
        }
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
        // JSON encoding and decoding
        guard let body = try? JSONEncoder().encode(modifiedTravel) else {
            print("Error encoding user data for PUT")
            throw NSError(domain: "UpdateTravelError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to encode travel."])
        }
        let decoder = JSONDecoder()
        
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/travels/user") else {
            print("Invalid URL used to retrieve travels from DB")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        // perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
            
        // decode response
        do {
            let travel = try decoder.decode(Travel.self, from: data)
            return travel
        } catch {
            print("Failed to decode trave: \(error.localizedDescription)")
            throw NSError(domain: "GetTravelsError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode travels."])
        }
    }
    
    func deleteTravel(firebaseToken: String, travelID: Int) async throws {
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/travels/user/\(travelID)") else {
            print("Invalid URL used to retrieve travels from DB")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        
        // perform request
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
        } catch {
            throw error
        }
    }
}
