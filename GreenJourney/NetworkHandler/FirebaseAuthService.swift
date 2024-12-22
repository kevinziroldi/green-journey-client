import FirebaseAuth

class FirebaseAuthService: FirebaseAuthServiceProtocol {
    func createUserFirebase(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func getFirebaseToken(firebaseUser: FirebaseAuth.User) async throws -> String {
        return try await firebaseUser.getIDToken()
    }
}
