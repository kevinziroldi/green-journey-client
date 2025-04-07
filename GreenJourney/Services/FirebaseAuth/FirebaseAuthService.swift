import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

class FirebaseAuthService: FirebaseAuthServiceProtocol {
    private var currentUser: FirebaseAuth.User?
    private var handler = Auth.auth().addStateDidChangeListener{_,_ in }

    init() {
        handler = Auth.auth().addStateDidChangeListener { auth, user in
            self.currentUser = user
        }
    }
    deinit {
        Auth.auth().removeStateDidChangeListener(handler)
    }
    
    func signInWithCredentials(email: String, password: String) async throws -> Bool {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return authDataResult.user.isEmailVerified
    }
    
    func signInWithGoogle() async throws -> Bool {
        // Google signin configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw FirebaseAuthServiceError.signInWithGoogleFailed
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // get root controller to show Google login screen
        guard
            let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = await windowScene.windows.first,
            let rootViewController = await window.rootViewController
        else {
            throw FirebaseAuthServiceError.signInWithGoogleFailed
        }
        
        // Google authentication
        let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = userAuthentication.user.idToken else {
            throw FirebaseAuthServiceError.signInWithGoogleFailed
        }
        
        // create Firebase credentials
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: userAuthentication.user.accessToken.tokenString)
        
        // signin with Firebase
        let authResult = try await Auth.auth().signIn(with: credential)
        
        guard let additionalUserInfo = authResult.additionalUserInfo else {
            throw FirebaseAuthServiceError.signInWithGoogleFailed
        }
        
        return additionalUserInfo.isNewUser
    }
    
    func createFirebaseUser(email: String, password: String) async throws -> String {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return authDataResult.user.uid
    }
    
    func sendEmailVerification() async throws {
        if let firebaseUser = Auth.auth().currentUser {
            try await firebaseUser.sendEmailVerification()
        } else {
            throw FirebaseAuthServiceError.sendEmailVerificationFailed
        }
    }
    
    func isEmailVerified() throws -> Bool {
        var result: Bool = false
        let handle = Auth.auth().addStateDidChangeListener { auth, user in
          result = user?.isEmailVerified ?? false
        }
        return result
    }
    
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func deleteFirebaseUser() async throws {
        if let firebaseUser = Auth.auth().currentUser {
            try await firebaseUser.delete()
        } else {
            throw FirebaseAuthServiceError.deleteFirebaseUserFailed
        }
    }
    
    func getFirebaseToken() async throws -> String {
        if let firebaseUser = Auth.auth().currentUser {
            return try await firebaseUser.getIDToken()
        } else {
            throw FirebaseAuthServiceError.getFirebaseTokenFailed
        }
    }
    
    func getFirebaseUID() async throws -> String {
        if let firebaseUser = Auth.auth().currentUser {
            return firebaseUser.uid
        } else {
            throw FirebaseAuthServiceError.getFirebaseUIDFailed
        }
    }
    
    func getUserFullName() async throws -> String {
        if let firebaseUser = Auth.auth().currentUser {
            if let name = firebaseUser.displayName {
                return name
            }
        }
        throw FirebaseAuthServiceError.getUserFullNameFailed
    }
    
    func reloadFirebaseUser() async throws {
        if let firebaseUser = Auth.auth().currentUser {
            try await firebaseUser.reload()
        } else {
            throw FirebaseAuthServiceError.reloadUserFailed
        }
    }
}
