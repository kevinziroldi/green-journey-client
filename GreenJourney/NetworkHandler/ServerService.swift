import Foundation

class ServerService: ServerServiceProtocol {
    func saveUserToServer(firstName: String, lastName: String, firebaseUID: String, firebaseToken: String) async throws {
        let baseURL = NetworkHandler.shared.getBaseURL()
        guard let url = URL(string: "\(baseURL)/users/user") else {
            throw URLError(.badURL)
        }
        
        let user = User(firstName: firstName, lastName: lastName, firebaseUID: firebaseUID, scoreShortDistance: 0, scoreLongDistance: 0)
        // JSON encoding
        guard let body = try? JSONEncoder().encode(user) else {
            throw EncodingError.invalidValue(user, EncodingError.Context(codingPath: [], debugDescription: "Error encoding user data"))
        }

        // POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
        } catch {
            throw error
        }
    }
}
