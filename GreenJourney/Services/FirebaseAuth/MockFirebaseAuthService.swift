class MockFirebaseAuthService: FirebaseAuthServiceProtocol {
    var shouldSucceed: Bool = true
    var emailVerified: Bool = true
    var isNewUser: Bool = true
    
    func signInWithCredentials(email: String, password: String) async throws -> Bool {
        if shouldSucceed {
            return emailVerified
        } else {
            throw FirebaseAuthServiceError.invalidCredentials
        }
    }
    
    func createFirebaseUser(email: String, password: String) async throws -> String {
        if shouldSucceed {
            return "firebase_uid"
        } else {
            throw FirebaseAuthServiceError.createFirebaseUserFailed
        }
    }
        
    func sendEmailVerification() async throws {
        if !shouldSucceed {
            throw FirebaseAuthServiceError.sendEmailVerificationFailed
        }
        // nothing to do
    }
    
    func isEmailVerified() async throws -> Bool {
        if shouldSucceed {
            return emailVerified
        } else {
            throw FirebaseAuthServiceError.isEmailVerifiedFailed
        }
    }
    
    func sendPasswordReset(email: String) async throws {
        if !shouldSucceed {
            throw FirebaseAuthServiceError.resetPasswordFailed
        }
    }
    
    func signInWithGoogle() async throws -> Bool {
        if shouldSucceed {
            return isNewUser
        } else {
            throw FirebaseAuthServiceError.signInWithGoogleFailed
        }
    }
    
    func deleteFirebaseUser() async throws {
        if !shouldSucceed {
            throw FirebaseAuthServiceError.deleteFirebaseUserFailed
        }
        // nothing to do
    }
    
    func getFirebaseToken() async throws -> String {
        if shouldSucceed {
            return "firebase_token"
        } else {
            throw FirebaseAuthServiceError.getFirebaseTokenFailed
        }
    }
    
    func getFirebaseUID() async throws -> String {
        if shouldSucceed {
            return "firebase_uid"
        } else {
            throw FirebaseAuthServiceError.getFirebaseUIDFailed
        }
    }
    
    func getUserFullName() async throws -> String {
        if shouldSucceed {
            return "full name"
        } else {
            throw FirebaseAuthServiceError.getUserFullNameFailed
        }
    }
    
    func reloadFirebaseUser() async throws {
        if !shouldSucceed {
            throw FirebaseAuthServiceError.reloadUserFailed
        }
        // nothing to do
    }
}

