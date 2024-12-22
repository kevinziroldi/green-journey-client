protocol ServerServiceProtocol {
    func saveUserToServer(firstName: String, lastName: String, firebaseUID: String, firebaseToken: String) async throws
    func getUserFromServer(firebaseToken: String) async throws -> User
    func fetchTravelsFromServer(firebaseToken: String) async throws -> [TravelDetails]
}
