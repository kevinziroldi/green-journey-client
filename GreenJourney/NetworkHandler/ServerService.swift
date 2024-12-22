import FirebaseAuth
import Foundation

class ServerService: ServerServiceProtocol {
    let firebaseAuthService: FirebaseAuthServiceProtocol
    
    init() {
        firebaseAuthService = FirebaseAuthService()
    }
    
    func saveUserToServer(firstName: String, lastName: String, firebaseUID: String, firebaseToken: String) async throws {
        let user = User(firstName: firstName, lastName: lastName, firebaseUID: firebaseUID, scoreShortDistance: 0, scoreLongDistance: 0)
        // JSON encoding
        guard let body = try? JSONEncoder().encode(user) else {
            throw EncodingError.invalidValue(user, EncodingError.Context(codingPath: [], debugDescription: "Error encoding user data"))
        }

        // build request
        let baseURL = NetworkHandler.shared.getBaseURL()
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
    
    func getUserFromServer(firebaseToken: String) async throws -> User {
        // build request
        let baseURL = NetworkHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/users/user") else {
            print("Invalid URL used to retrieve user from DB")
            throw NSError(domain: "FetchUserError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid base URL."])
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
            throw NSError(domain: "FetchUserError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user."])
        }
    }
    
    func fetchTravelsFromServer(firebaseToken: String) async throws -> [TravelDetails] {
        // build request
        let baseURL = NetworkHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/travels/user") else {
            print("Invalid URL used to retrieve travels from DB")
            throw NSError(domain: "FetchTravelsError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid base URL"])
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
            throw NSError(domain: "FetchTravelsError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode travels."])
        }
    }
}
