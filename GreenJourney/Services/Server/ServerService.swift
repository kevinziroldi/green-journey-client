import FirebaseAuth
import Foundation

class ServerService: ServerServiceProtocol {
    private let firebaseAuthService: FirebaseAuthService = FirebaseAuthService()
    
    func getFirebaseToken() async throws -> String {
        guard let firebaseUser = Auth.auth().currentUser else {
            print("Error retrieving firebase user")
            throw NSError(domain: "GetFirebaseTokenError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to get Firebase token."])
        }
        return try await firebaseAuthService.getFirebaseToken(firebaseUser: firebaseUser)
    }
    
    func saveUser(firstName: String, lastName: String, firebaseUID: String) async throws {
        let firebaseToken = try await getFirebaseToken()
        
        let user = User(firstName: firstName, lastName: lastName, firebaseUID: firebaseUID, scoreShortDistance: 0, scoreLongDistance: 0)
        // JSON encoding
        guard let body = try? JSONEncoder().encode(user) else {
            throw EncodingError.invalidValue(user, EncodingError.Context(codingPath: [], debugDescription: "Error encoding user data"))
        }

        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string: "\(baseURL)/users/user") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
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
    
    func getUser() async throws -> User {
        let firebaseToken = try await getFirebaseToken()
        
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/users/user") else {
            print("Invalid URL used to retrieve user from DB")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        
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
            let user = try decoder.decode(User.self, from: data)
            return user
        } catch {
            print("Failed to decode user: \(error.localizedDescription)")
            throw NSError(domain: "GetUserError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user."])
        }
    }
    
    func modifyUser(modifiedUser: User) async throws -> User {
        let firebaseToken = try await getFirebaseToken()

        // JSON encoding
        guard let body = try? JSONEncoder().encode(modifiedUser) else {
            print("Error encoding user data for PUT")
            throw NSError(domain: "ModifyUserError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to modify user."])
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string: "\(baseURL)/users") else {
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
            let user = try decoder.decode(User.self, from: data)
            return user
        } catch {
            print("Failed to decode user: \(error.localizedDescription)")
            throw NSError(domain: "GetUserError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user."])
        }
    }
    
    func getRanking(userID: Int) async throws -> RankingResponse {
        // create request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/ranking?id=\(userID)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // no authentication needed
        
        // decoder
        let decoder = JSONDecoder()
        
        // perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let ranking = try decoder.decode(RankingResponse.self, from: data)
            return ranking
        } catch {
            print("Failed to decode ranking: \(error.localizedDescription)")
            throw NSError(domain: "GetRankingError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode ranking."])
        }
    }
    
    func getReviewsForCity(iata: String, countryCode: String) async throws -> CityReviewElement {
        let firebaseToken = try await getFirebaseToken()
        
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
    
    func uploadReview(review: Review) async throws -> Review {
        let firebaseToken = try await getFirebaseToken()
        
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
    
    func modifyReview(modifiedReview: Review) async throws -> Review {
        let firebaseToken = try await getFirebaseToken()
        
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
    
    func deleteReview(reviewID: Int) async throws {
        let firebaseToken = try await getFirebaseToken()
        
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
    
    func saveTravel(travelDetails: TravelDetails) async throws -> TravelDetails {
        let firebaseToken = try await getFirebaseToken()
        
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
    
    func getTravels() async throws -> [TravelDetails] {
        let firebaseToken = try await getFirebaseToken()
        
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
    
    func updateTravel(modifiedTravel: Travel) async throws -> Travel {
        let firebaseToken = try await getFirebaseToken()
        
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
    
    func deleteTravel(travelID: Int) async throws {
        let firebaseToken = try await getFirebaseToken()
        
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
extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

