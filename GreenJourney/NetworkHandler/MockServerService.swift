//: ServerServiceProtocol

class MockServerService {
    func saveUserToServer(firstName: String, lastName: String, firebaseUID: String, firebaseToken: String) async throws {}
    
    func fetchTravelsFromServer(firebaseToken: String) async throws -> [TravelDetails] {
        return []
    }
}
