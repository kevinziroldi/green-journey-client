protocol ServerServiceProtocol {
    func saveUserToServer(firstName: String, lastName: String, firebaseUID: String, firebaseToken: String) async throws
}
