class MockFirebaseAuthService: FirebaseAuthServiceProtocol {
    var correctCredentials: Bool = true
    var emailVerified: Bool = true
    var resetPasswordShouldSucceed: Bool = true
    
    func signInWithCredentials(email: String, password: String) async throws -> Bool {
        if correctCredentials {
            return emailVerified
        } else {
            throw MockFirebaseAuthError.invalidCredentials
        }
    }
    
    func signInWithGoogle() async throws -> Bool {
        // nothing to do
        return true
        // or false ???
    }
    
    func createFirebaseUser(email: String, password: String) async throws -> String {
        return "firebase_uid"
    }
    
    func sendEmailVerification() async throws {
        // nothing to do
    }
    
    func isEmailVerified() async throws -> Bool {
        return true
        // or false
    }
    
    func sendPasswordReset(email: String) async throws {
        if !resetPasswordShouldSucceed {
            throw MockFirebaseAuthError.resetPasswordFailed
        }
    }
    
    func deleteFirebaseUser() async throws {
        // nothing to do
    }
    
    func getFirebaseToken() async throws -> String {
        return "firebase_token"
    }
    
    func getFirebaseUID() async throws -> String {
        return "firebase_uid"
    }
    
    func getUserFullName() async throws -> String {
        return "full name"
    }
    
    func reloadFirebaseUser() async throws {
        // nothing to do 
    }
}

