class MockFirebaseAuthService: FirebaseAuthServiceProtocol {
    var shouldSucceed: Bool = true
    var emailVerified: Bool = true
    var isNewUser: Bool = true
    
    func signInWithCredentials(email: String, password: String) async throws -> Bool {
        if shouldSucceed {
            return emailVerified
        } else {
            throw MockFirebaseAuthError.invalidCredentials
        }
    }
    
    func createFirebaseUser(email: String, password: String) async throws -> String {
        if shouldSucceed {
            return "firebase_uid"
        } else {
            throw MockFirebaseAuthError.createFirebaseUserFailed
        }
    }
        
    func sendEmailVerification() async throws {
        if !shouldSucceed {
            throw MockFirebaseAuthError.sendEmailVerificationFailed
        }
        // nothing to do
    }
    
    func isEmailVerified() async throws -> Bool {
        if shouldSucceed {
            return emailVerified
        } else {
            throw MockFirebaseAuthError.isEmailVerifiedFailed
        }
    }
    
    func sendPasswordReset(email: String) async throws {
        if !shouldSucceed {
            throw MockFirebaseAuthError.resetPasswordFailed
        }
    }
    
    func signInWithGoogle() async throws -> Bool {
        if shouldSucceed {
            return isNewUser
        } else {
            throw MockFirebaseAuthError.signInWithGoogleFailed
        }
    }
    
    func deleteFirebaseUser() async throws {
        if !shouldSucceed {
            throw MockFirebaseAuthError.deleteFirebaseUserFailed
        }
        // nothing to do
    }
    
    func getFirebaseToken() async throws -> String {
        if shouldSucceed {
            return "firebase_token"
        } else {
            throw MockFirebaseAuthError.getFirebaseTokenFailed
        }
    }
    
    func getFirebaseUID() async throws -> String {
        if shouldSucceed {
            return "firebase_uid"
        } else {
            throw MockFirebaseAuthError.getFirebaseUIDFailed
        }
    }
    
    func getUserFullName() async throws -> String {
        if shouldSucceed {
            return "full name"
        } else {
            throw MockFirebaseAuthError.getUserFullNameFailed
        }
    }
    
    func reloadFirebaseUser() async throws {
        if !shouldSucceed {
            throw MockFirebaseAuthError.reloadUserFailed
        }
        // nothing to do
    }
}

