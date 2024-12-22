import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import SwiftData
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    let uuid: UUID = UUID()
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var errorMessage: String?
    @Published var resendEmail: String?
    @Published public var isLogged: Bool = false
    @Published var emailVerified: Bool = false
    @Published var isEmailVerificationActiveLogin: Bool = false
    @Published var isEmailVerificationActiveSignup: Bool = false
    //swift data model context
    private var modelContext: ModelContext
    // external services
    private let serverService: ServerServiceProtocol
    private let firebaseAuthService: FirebaseAuthService
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.isLogged = false
        
        // TODO mock vs not mock
        self.serverService = ServerService()
        self.firebaseAuthService = FirebaseAuthService()
    }
    
    func login() {
        Task { @MainActor in
            // input check and validation
            guard !email.isEmpty, !password.isEmpty else {
                errorMessage = "Insert email and password."
                return
            }
            
            do {
                let authResult = try await firebaseAuthService.signIn(email: email, password: password)
                let firebaseUser = authResult.user
                self.emailVerified = firebaseUser.isEmailVerified
                
                if firebaseUser.isEmailVerified == true {
                    let firebaseToken = try await firebaseAuthService.getFirebaseToken(firebaseUser: firebaseUser)
                    self.errorMessage = nil
                    self.getUserFromServer(firebaseToken: firebaseToken)
                } else {
                    self.isEmailVerificationActiveLogin = true
                }
            } catch {
                self.errorMessage = "Error during authentication"
                return
            }
        }
    }
    
    func logout() {
        do {
            let users = try modelContext.fetch(FetchDescriptor<User>())
            
            for user in users {
                modelContext.delete(user)
            }
             
            try modelContext.save()
            print("User successfully logged out and removed from SwiftData")
        } catch {
            print("Error while saving context after logout: \(error)")
        }
        
        self.isLogged = false
    }
    
    func resetPassword(email: String) {
        Task { @MainActor in
            guard(!email.isEmpty) else {
                errorMessage = "Insert email"
                return
            }
            errorMessage = nil
            
            do {
                try await firebaseAuthService.sendPasswordReset(email: email)
                print("Email for password reset sent")
                self.resendEmail = "Email sent, check your inbox"
            } catch {
                print("Error in sending email for password recovery: \(error.localizedDescription)")
                self.errorMessage = "Error in sending email for password recovery"
                self.resendEmail = nil
            }
        }
    }
    
    func signUp() {
        Task { @MainActor in
            guard !email.isEmpty, !password.isEmpty, !repeatPassword.isEmpty else {
                errorMessage = "Insert email and password"
                return
            }
            guard !firstName.isEmpty, !lastName.isEmpty else {
                errorMessage = "Insert first name and last name"
                return
            }
            if (password != repeatPassword) {
                errorMessage = "Passwords do not match"
                return
            }
            
            // Firebase call, create account
            do {
                let authResult = try await firebaseAuthService.createFirebaseUser(email: email, password: password)
                let firebaseToken = try await firebaseAuthService.getFirebaseToken(firebaseUser: authResult.user)
                
                print("Token retrieved")
                do {
                    try await serverService.saveUserToServer(firebaseToken: firebaseToken, firstName: self.firstName, lastName: self.lastName, firebaseUID: authResult.user.uid)
                    
                    print("User data posted successfully.")
                    
                    self.errorMessage = nil
                    self.sendEmailVerification()
                    self.isEmailVerificationActiveSignup = true
                } catch {
                    self.errorMessage = "Error creating account"
                    print("Error posting user data: \(error.localizedDescription)")
                    
                    // delete user
                    guard let firebaseUser = Auth.auth().currentUser else {
                        print("Error getting firebase user")
                        return
                    }
                    do {
                        try await firebaseAuthService.deleteFirebaseUser(firebaseUser: firebaseUser)
                        // account deleted
                        print("User deleted from firebase")
                    }catch {
                        // error happened
                        print("Error deleting user from Firebase: \(error.localizedDescription)")
                    }
                    return
                }
            } catch {
                self.errorMessage = "Error creating account"
                return
            }
        }
    }
    
    func sendEmailVerification() {
        Task { @MainActor in
            guard let firebaseUser = Auth.auth().currentUser else {
                print("Firebase user is nil")
                self.errorMessage = "Error snending email verification"
                return
            }
        
            do {
                try await firebaseAuthService.sendEmailVerification(firebaseUser: firebaseUser)
            }catch {
                print("Error sending email verification: \(error.localizedDescription)")
                self.errorMessage = "Error sending email verification"
            }
        }
    }
    
    func verifyEmail() {
        Task { @MainActor in
            guard let firebaseUser = Auth.auth().currentUser else {
                print("No Firebase user present")
                self.errorMessage = "Error verifying email"
                return
            }
            
            do {
                try await firebaseAuthService.reloadFirebaseUser(firebaseUser: firebaseUser)
                
                // need to get Firebase user again after reload
                guard let firebaseUser = Auth.auth().currentUser else {
                    print("No Firebase user present")
                    self.errorMessage = "Error verifying email"
                    return
                }
                
                if firebaseUser.isEmailVerified == true {
                    print("Email verified")
                    self.errorMessage = nil
                    self.emailVerified = true
                    self.isEmailVerificationActiveLogin = false
                    self.isEmailVerificationActiveSignup = false
                    
                    // save user to swift data
                    let firebaseToken = try await firebaseAuthService.getFirebaseToken(firebaseUser: firebaseUser)
                    self.getUserFromServer(firebaseToken: firebaseToken)
                } else {
                    self.errorMessage = "Email has not been verified yet"
                    print("Email not verified")
                }
            }catch {
                print("Error reloading user: \(error.localizedDescription)")
                self.errorMessage = "Error verifying email"
                return
            }
        }
    }
    
    private func getUserFromServer(firebaseToken: String) {
        Task { @MainActor in
            do {
                let user = try await serverService.getUserFromServer(firebaseToken: firebaseToken)
                self.saveUserToSwiftData(serverUser: user)
            }catch {
                print("Error getting user from server")
                return
            }
        }
    }
    
    private func saveUserToSwiftData(serverUser: User?) {
        if let user = serverUser {
            // check no user logged
            do {
                let users = try modelContext.fetch(FetchDescriptor<User>())
                if users.count > 0 {
                    for user in users {
                        modelContext.delete(user)
                    }
                    try modelContext.save()
                    print("Some user is already logged and is being removed, new user loaded to SwiftData")
                }
            } catch {
                self.errorMessage = "Error logging in"
                print("Error while checking number of users: \(error)")
                return
            }
            
            // add user to context
            modelContext.insert(user)
            
            // save user in SwiftData
            do {
                try modelContext.save()
                
                // user logged
                self.isLogged = true
                
                print("Saved user (firebaseUID " + user.firebaseUID + ") in SwiftData")
            } catch {
                print("Error while saving user to SwiftData: \(error)")
                self.errorMessage = "Error logging in"
                return
            }
        }
    }
    
    func signInWithGoogle() {
        Task { @MainActor in
            do {
                // Google signin configuration
                guard let clientID = FirebaseApp.app()?.options.clientID else {
                    fatalError("No client ID found in Firebase")
                }
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.configuration = config
                
                // get root controller to show Google login screen
                guard
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let window = windowScene.windows.first,
                    let rootViewController = window.rootViewController
                else {
                    self.errorMessage = "Error signing in with Google"
                    print("There is no root view controller")
                    return
                }
                
                // Google authentication
                let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                guard let idToken = userAuthentication.user.idToken else {
                    self.errorMessage = "Error signing in with Google"
                    print("ID token Missing")
                    return
                }
                
                // create Firebase credentials
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: userAuthentication.user.accessToken.tokenString)

                // signin with Firebase
                let authResult = try await Auth.auth().signIn(with: credential)
                guard let additionalUserInfo = authResult.additionalUserInfo else {
                    self.errorMessage = "Error signing in with Google"
                    return
                }
                let firebaseUser = authResult.user
                let firebaseToken = try await firebaseAuthService.getFirebaseToken(firebaseUser: authResult.user)
                
                if (additionalUserInfo.isNewUser) {
                    // if new user, save to server (signup)
                    
                    let fullName = firebaseUser.displayName
                    let parts = fullName?.components(separatedBy: " ")
                    self.firstName = parts![0]
                    self.lastName = parts![1]
                    
                    do {
                        try await serverService.saveUserToServer(firebaseToken: firebaseToken, firstName: self.firstName, lastName: self.lastName, firebaseUID: firebaseUser.uid)
                        print("User data posted successfully.")
                        self.getUserFromServer(firebaseToken: firebaseToken)
                    } catch {
                        self.errorMessage = "Error signing in with Google"
                        print("Error posting user data: \(error.localizedDescription)")
                       
                        // delete Firebase user
                        do {
                            try await firebaseAuthService.deleteFirebaseUser(firebaseUser: firebaseUser)
                            // account deleted
                            print("User deleted from Firebase")
                        }catch {
                            // an error happened
                            self.errorMessage = "Error signing in with Google"
                            print("Error deleting user from Firebase: \(error.localizedDescription)")
                            return
                        }
                        return
                    }
                } else {
                    // if not new, get from server (login)
                    
                    self.getUserFromServer(firebaseToken: firebaseToken)
                }
            } catch {
                self.errorMessage = "Error signing in with Google"
                print("Error signing in with Google: \(error.localizedDescription)")
                return
            }
        }
    }
}

extension AuthenticationViewModel: Hashable {
    static func == (lhs: AuthenticationViewModel, rhs: AuthenticationViewModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
