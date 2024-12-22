import FirebaseAuth

protocol FirebaseAuthServiceProtocol {
    func createUserFirebase(email: String, password: String) async throws -> AuthDataResult
    func getFirebaseToken(firebaseUser: FirebaseAuth.User) async throws -> String
}
