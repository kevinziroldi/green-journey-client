import FirebaseAuth

// TODO sostituire con mock !!!

class MockFirebaseAuthService: FirebaseAuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func createFirebaseUser(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func sendEmailVerification(firebaseUser: FirebaseAuth.User) async throws {
        try await firebaseUser.sendEmailVerification()
    }
    
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func deleteFirebaseUser(firebaseUser: FirebaseAuth.User) async throws {
        try await firebaseUser.delete()
    }
    
    func getFirebaseToken(firebaseUser: FirebaseAuth.User) async throws -> String {
        return try await firebaseUser.getIDToken()
    }
    
    func reloadFirebaseUser(firebaseUser: FirebaseAuth.User) async throws {
        try await firebaseUser.reload()
    }
}

