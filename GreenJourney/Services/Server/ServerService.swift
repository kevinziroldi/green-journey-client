import FirebaseAuth
import Foundation

class ServerService: ServerServiceProtocol {
    private let firebaseAuthService: FirebaseAuthServiceProtocol
    
    init() {
        self.firebaseAuthService = ServiceFactory.shared.getFirebaseAuthService()
    }
    
    private func isConnectionAvailable() -> Bool {
        return NetworkMonitor.shared.getNetworkState()
    }
    
    func saveUser(firstName: String, lastName: String, firebaseUID: String) async throws {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        let firebaseToken = try await firebaseAuthService.getFirebaseToken()
        
        let user = User(firstName: firstName, lastName: lastName, firebaseUID: firebaseUID, scoreShortDistance: 0, scoreLongDistance: 0)
        // JSON encoding
        guard let body = try? JSONEncoder().encode(user) else {
            throw ServerServiceError.saveUserFailed
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
        
        let session = URLHandler.shared.getURLSession()
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    func getUser() async throws -> User {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        let firebaseToken = try await firebaseAuthService.getFirebaseToken()
        
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
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let user = try decoder.decode(User.self, from: data)
            return user
        } catch {
            print("Failed to decode user")
            throw ServerServiceError.getUserFailed
        }
    }
    
    func modifyUser(modifiedUser: User) async throws -> User {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        let firebaseToken = try await firebaseAuthService.getFirebaseToken()
        
        // JSON encoding
        guard let body = try? JSONEncoder().encode(modifiedUser) else {
            print("Error encoding user data for PUT")
            throw ServerServiceError.modifyUserFailed
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
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let user = try decoder.decode(User.self, from: data)
            return user
        } catch {
            print("Failed to decode user")
            throw ServerServiceError.modifyUserFailed
        }
    }
    
    func getRanking(userID: Int) async throws -> RankingResponse {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
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
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let ranking = try decoder.decode(RankingResponse.self, from: data)
            return ranking
        } catch {
            print("Failed to decode ranking")
            throw ServerServiceError.getRankingFailed
        }
    }
    
    func getFirstReviewsForCity(iata: String, countryCode: String) async throws -> CityReviewElement {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/reviews/first?city_iata=\(iata)&country_code=\(countryCode)") else {
            print("Invalid URL")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // perform request
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let reviews = try decoder.decode(CityReviewElement.self, from: data)
            return reviews
        } catch {
            print("Failed to decode city review elements")
            throw ServerServiceError.getBestReviewsFailed
        }
    }
    
    func getLastReviewsForCity(iata: String, countryCode: String) async throws -> CityReviewElement {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/reviews/last?city_iata=\(iata)&country_code=\(countryCode)") else {
            print("Invalid URL")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // perform request
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let reviews = try decoder.decode(CityReviewElement.self, from: data)
            return reviews
        } catch {
            print("Failed to decode city review elements")
            throw ServerServiceError.getBestReviewsFailed
        }
    }
    
    func getReviewsForCity(iata: String, countryCode: String, reviewID: Int, direction: Bool) async throws ->
    CityReviewElement {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/reviews?city_iata=\(iata)&country_code=\(countryCode)&review_id=\(reviewID)&direction=\(direction)") else {
            print("Invalid URL")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // perform request
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let reviews = try decoder.decode(CityReviewElement.self, from: data)
            return reviews
        } catch {
            print("Failed to decode reviews")
            throw ServerServiceError.getReviewsCityFailed
        }
    }
    
    func getBestReviewedCities() async throws -> [CityReviewElement] {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
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
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let reviews = try decoder.decode([CityReviewElement].self, from: data)
            return reviews
        } catch {
            print("Failed to decode city review elements")
            throw ServerServiceError.getBestReviewsFailed
        }
    }
    
    func uploadReview(review: Review) async throws -> Review {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        let firebaseToken = try await firebaseAuthService.getFirebaseToken()
        
        // JSON encoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        guard let body = try? encoder.encode(review) else {
            print("Error encoding review data")
            throw ServerServiceError.uploadReviewFailed
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
        
        print(String(data: body, encoding: .utf8)!)
        
        // perform request
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let review = try decoder.decode(Review.self, from: data)
            return review
        } catch {
            print("Failed to decode review")
            throw ServerServiceError.uploadReviewFailed
        }
    }
    
    func modifyReview(modifiedReview: Review) async throws -> Review {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        let firebaseToken = try await firebaseAuthService.getFirebaseToken()
        
        // JSON encoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        guard let body = try? encoder.encode(modifiedReview) else {
            print("Error encoding review data for PUT")
            throw ServerServiceError.modifyReviewFailed
        }
        
        // extract reviewID
        guard let reviewID = modifiedReview.reviewID else {
            print("Review ID missing")
            throw ServerServiceError.modifyReviewFailed
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
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let review = try decoder.decode(Review.self, from: data)
            return review
        } catch {
            print("Failed to decode review")
            throw ServerServiceError.modifyReviewFailed
        }
    }
    
    func deleteReview(reviewID: Int) async throws {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        let firebaseToken = try await firebaseAuthService.getFirebaseToken()
        
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
        let session = URLHandler.shared.getURLSession()
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    func computeRoutes(departureIata: String, departureCountryCode: String,
                       destinationIata: String, destinationCountryCode: String,
                       date: String, time: String, isOutward: Bool) async throws -> [TravelOption] {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
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
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let travelOptionsRaw = try decoder.decode(TravelOptionsResponse.self, from: data)
            
            // convert to [TravelOption]
            var travelOptions: [TravelOption] = []
            for segments in travelOptionsRaw.options {
                travelOptions.append(TravelOption(segments: segments))
            }
            return travelOptions
        } catch {
            print("Failed to decode review")
            throw ServerServiceError.computeRoutesFailed
        }
    }
    
    func saveTravel(travelDetails: TravelDetails) async throws -> TravelDetails {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        let firebaseToken = try await firebaseAuthService.getFirebaseToken()
        
        // JSON encoding
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let body = try? encoder.encode(travelDetails) else {
            print("Error encoding travel data")
            throw ServerServiceError.saveTravelFailed
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
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let travelDetails = try decoder.decode(TravelDetails.self, from: data)
            return travelDetails
        } catch {
            print("Failed to decode review")
            throw ServerServiceError.saveTravelFailed
        }
    }
    
    func getTravels() async throws -> [TravelDetails] {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        let firebaseToken = try await firebaseAuthService.getFirebaseToken()
        
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/travels/user") else {
            print("Invalid URL")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        
        // build JSON decoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // perform request
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let travelDetailsList = try decoder.decode([TravelDetails].self, from: data)
            return travelDetailsList
        } catch {
            print("Failed to decode travels")
            throw ServerServiceError.getTravelsFailed
        }
    }
    
    func updateTravel(modifiedTravel: Travel) async throws -> Travel {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        let firebaseToken = try await firebaseAuthService.getFirebaseToken()
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        // JSON encoding and decoding
        guard let body = try? encoder.encode(modifiedTravel) else {
            print("Error encoding user data for PUT")
            throw ServerServiceError.modifyTravelFailed
        }
        
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
        let session = URLHandler.shared.getURLSession()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // decode response
        do {
            let travel = try decoder.decode(Travel.self, from: data)
            return travel
        } catch {
            print("Failed to decode travel")
            throw ServerServiceError.modifyTravelFailed
        }
    }
    
    func deleteTravel(travelID: Int) async throws {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        let firebaseToken = try await firebaseAuthService.getFirebaseToken()
        
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
        let session = URLHandler.shared.getURLSession()
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    func resetTestDatabase() async throws {
        if !isConnectionAvailable() {
            throw URLError(.notConnectedToInternet)
        }
        
        // build request
        let baseURL = URLHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/resetTestDatabase") else {
            print("Invalid URL used to retrieve travels from DB")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // perform request
        let session = URLHandler.shared.getURLSession()
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
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

