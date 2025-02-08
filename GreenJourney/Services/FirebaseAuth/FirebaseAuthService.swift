import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

class FirebaseAuthService: FirebaseAuthServiceProtocol {
    func signInWithCredentials(email: String, password: String) async throws -> Bool {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return authDataResult.user.isEmailVerified
    }
    
    func signInWithGoogle() async throws -> Bool {
        // Google signin configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // get root controller to show Google login screen
        guard
            let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = await windowScene.windows.first,
            let rootViewController = await window.rootViewController
        else {
            // TODO ok ?
            throw NSError()
        }
        
        // Google authentication
        let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = userAuthentication.user.idToken else {
            // TODO ok ?
            throw NSError()
        }
        
        // create Firebase credentials
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: userAuthentication.user.accessToken.tokenString)
        
        // signin with Firebase
        let authResult = try await Auth.auth().signIn(with: credential)
        
        guard let additionalUserInfo = authResult.additionalUserInfo else {
            // TODO ok ?
            throw NSError()
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
            throw NSError()
        }
    }
    
    func isEmailVerified() async throws -> Bool {
        if let firebaseUser = Auth.auth().currentUser {
            return firebaseUser.isEmailVerified
        } else {
            // TODO ok ?
            throw NSError()
        }
    }
    
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func deleteFirebaseUser() async throws {
        if let firebaseUser = Auth.auth().currentUser {
            try await firebaseUser.delete()
        } else {
            // TODO ok ?
            throw NSError()
        }
    }
    
    func getFirebaseToken() async throws -> String {
        if let firebaseUser = Auth.auth().currentUser {
            return try await firebaseUser.getIDToken()
        } else {
            // TODO ok ?
            throw NSError()
        }
    }
    
    func getFirebaseUID() async throws -> String {
        if let firebaseUser = Auth.auth().currentUser {
            return firebaseUser.uid
        } else {
            // TODO ok ?
            throw NSError()
        }
    }
    
    func getUserFullName() async throws -> String {
        if let firebaseUser = Auth.auth().currentUser {
            if let name = firebaseUser.displayName {
                return name
            }
        }
        throw NSError()
    }
    
    func reloadFirebaseUser() async throws {
        if let firebaseUser = Auth.auth().currentUser {
            try await firebaseUser.reload()
        } else {
            // TODO ok ?
            throw NSError()
        }
    }
}
