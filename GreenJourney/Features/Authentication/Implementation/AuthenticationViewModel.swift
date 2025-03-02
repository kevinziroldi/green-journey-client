import SwiftData
import SwiftUI

@MainActor
class AuthenticationViewModel: ObservableObject {
    let uuid: UUID = UUID()
    
    //swift data model context
    private var modelContext: ModelContext
    // external services
    private let serverService: ServerServiceProtocol
    private let firebaseAuthService: FirebaseAuthServiceProtocol
    
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
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        self.modelContext = modelContext
        self.isLogged = false
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    
    func login() async {
        // input check and validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Insert email and password."
            return
        }
        
        do {
            let emailVerified = try await firebaseAuthService.signInWithCredentials(email: email, password: password)
            self.emailVerified = emailVerified
            
            if emailVerified == true {
                let firebaseToken = try await firebaseAuthService.getFirebaseToken()
                self.errorMessage = nil
                try await self.getUserFromServer()
            } else {
                self.isEmailVerificationActiveLogin = true
            }
        } catch {
            self.errorMessage = "Error during authentication"
            return
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
    
    func resetPassword(email: String) async {
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
    
    func signUp() async {
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
            let firebaseUID = try await firebaseAuthService.createFirebaseUser(email: email, password: password)
            do {
                try await serverService.saveUser(firstName: self.firstName, lastName: self.lastName, firebaseUID: firebaseUID)
                
                print("User data posted successfully.")
                
                self.errorMessage = nil
                await self.sendEmailVerification()
                self.isEmailVerificationActiveSignup = true
            } catch {
                self.errorMessage = "Error creating account"
                print("Error posting user data: \(error.localizedDescription)")
                
                // delete user
                do {
                    try await firebaseAuthService.deleteFirebaseUser()
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
    
    func sendEmailVerification() async {
        do {
            try await firebaseAuthService.sendEmailVerification()
        }catch {
            print("Error sending email verification: \(error.localizedDescription)")
            self.errorMessage = "Error sending email verification"
        }
    }
    
    func verifyEmail() async {
        do {
            try await firebaseAuthService.reloadFirebaseUser()
            
            // need to get Firebase user again after reload
            let isEmailVerified = try await firebaseAuthService.isEmailVerified()
            
            if isEmailVerified == true {
                print("Email verified")
                self.errorMessage = nil
                self.emailVerified = true
                self.isEmailVerificationActiveLogin = false
                self.isEmailVerificationActiveSignup = false
                
                // save user to swift data
                let firebaseToken = try await firebaseAuthService.getFirebaseToken()
                try await self.getUserFromServer()
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
    
    private func getUserFromServer() async throws {
        let user = try await serverService.getUser()
        self.saveUserToSwiftData(serverUser: user)
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
    
    func signInWithGoogle() async {
        do {
            let isNewUser = try await firebaseAuthService.signInWithGoogle()
            let firebaseToken = try await firebaseAuthService.getFirebaseToken()
            
            if isNewUser {
                // if new user, save to server (signup)
                let fullName = try await firebaseAuthService.getUserFullName()
                let parts = fullName.components(separatedBy: " ")
                self.firstName = parts[0]
                self.lastName = parts[1]
                
                do {
                    let firebaseUID = try await firebaseAuthService.getFirebaseUID()
                    try await serverService.saveUser(firstName: self.firstName, lastName: self.lastName, firebaseUID: firebaseUID)
                    print("User data posted successfully.")
                    try await self.getUserFromServer()
                } catch {
                    self.errorMessage = "Error signing in with Google"
                    print("Error posting user data: \(error.localizedDescription)")
                    
                    // delete Firebase user
                    do {
                        try await firebaseAuthService.deleteFirebaseUser()
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
                try await self.getUserFromServer()
            }
        } catch {
            self.errorMessage = "Error signing in with Google"
            print("Error signing in with Google: \(error.localizedDescription)")
            return
        }
    }
}

extension AuthenticationViewModel: Hashable {
    nonisolated static func == (lhs: AuthenticationViewModel, rhs: AuthenticationViewModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
