import SwiftData
import SwiftUI

@MainActor
class AuthenticationViewModel: ObservableObject {
    private let uuid: UUID = UUID()
    
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
    @Published var isLogged: Bool = false
    @Published var emailVerified: Bool = false
    @Published var isEmailVerificationActiveLogin: Bool = false
    @Published var isEmailVerificationActiveSignup: Bool = false
    @Published var isPresenting: Bool = false
    @Published var isLoading: Bool = false
    init(modelContext: ModelContext, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        self.modelContext = modelContext
        self.isLogged = false
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    
    func login() async {
        // input check and validation
        isLoading = true
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Insert email and password."
            isLoading = false
            return
        }
        
        do {
            let emailVerified = try await firebaseAuthService.signInWithCredentials(email: email, password: password)
            self.emailVerified = emailVerified
            
            if emailVerified == true {
                self.errorMessage = nil
                try await self.getUserFromServer()
            } else {
                self.isEmailVerificationActiveLogin = true
            }
            isLoading = false
        } catch {
            self.errorMessage = "Error during authentication"
            isLoading = false
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
            print("Error while saving context after logout")
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
            print("Error in sending email for password recovery")
            self.errorMessage = "Error in sending email for password recovery"
            self.resendEmail = nil
        }
    }
    
    func signUp() async {
        isLoading = true
        guard !email.isEmpty, !password.isEmpty, !repeatPassword.isEmpty else {
            errorMessage = "Insert email and password"
            isLoading = false
            return
        }
        guard !firstName.isEmpty, !lastName.isEmpty else {
            errorMessage = "Insert first name and last name"
            isLoading = false
            return
        }
        if (password != repeatPassword) {
            errorMessage = "Passwords do not match"
            isLoading = false
            return
        }
        
        // Firebase call, create account
        do {
            let firebaseUID = try await firebaseAuthService.createFirebaseUser(email: email, password: password)
            do {
                try await serverService.saveUser(firstName: self.firstName, lastName: self.lastName, firebaseUID: firebaseUID)
                
                print("User data posted successfully")
                
                self.errorMessage = nil
                await self.sendEmailVerification()
                self.isEmailVerificationActiveSignup = true
                isLoading = false
            } catch {
                self.errorMessage = "Error creating account"
                print("Error posting user data")
                isLoading = false
                // delete user
                do {
                    try await firebaseAuthService.deleteFirebaseUser()
                    // account deleted
                    print("User deleted from firebase")
                    isLoading = false
                }catch {
                    // error happened
                    print("Error deleting user from Firebase")
                    //2nd attempt
                    print("Second attempt")
                    try await firebaseAuthService.deleteFirebaseUser()
                    isLoading = false
                }
            }
        } catch {
            self.errorMessage = "\(error.localizedDescription)"
            isLoading = false
            return
        }
    }
    
    func sendEmailVerification() async {
        do {
            try await firebaseAuthService.sendEmailVerification()
        }catch {
            print("Error sending email verification")
            self.errorMessage = "Error sending email verification"
        }
    }
    
    func verifyEmail() async {
        do {
            try await firebaseAuthService.reloadFirebaseUser()
            
            // need to get Firebase user again after reload
            let isEmailVerified = try firebaseAuthService.isEmailVerified()
            
            if isEmailVerified == true {
                print("Email verified")
                self.errorMessage = nil
                self.emailVerified = true
                self.isEmailVerificationActiveLogin = false
                self.isEmailVerificationActiveSignup = false
                
                // save user to swift data
                try await self.getUserFromServer()
            } else {
                self.errorMessage = "Email has not been verified yet"
                print("Email not verified")
            }
        }catch {
            print("Error reloading user")
            self.errorMessage = "Error verifying email"
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
                print("Error while checking number of users")
                return
            }
            
            // add user to context
            modelContext.insert(user)
            
            // save user in SwiftData
            do {
                try modelContext.save()
                
                // user logged
                self.isLogged = true
                
                print("Saved user in SwiftData")
            } catch {
                print("Error while saving user to SwiftData")
                self.errorMessage = "Error logging in"
            }
        }
    }
    
    func updateUserFromServer() async {
        do {
            let newUser = try await serverService.getUser()
            
            let users = try modelContext.fetch(FetchDescriptor<User>())
            if users.count != 1 {
                for user in users {
                    modelContext.delete(user)
                }
                try modelContext.save()
            }
            if let user = users.first {
                user.firstName = newUser.firstName
                user.lastName = newUser.lastName
                user.birthDate = newUser.birthDate
                user.gender = newUser.gender
                user.streetName = newUser.streetName
                user.houseNumber = newUser.houseNumber
                user.zipCode = newUser.zipCode
                user.city = newUser.city
                user.scoreShortDistance = newUser.scoreShortDistance
                user.scoreLongDistance = newUser.scoreLongDistance
            }
            
            try modelContext.save()
        } catch {
            self.errorMessage = "Error updating user"
            print("Error while checking number of users")
            return
        }
    }
        
    func signInWithGoogle() async {
        do {
            let isNewUser = try await firebaseAuthService.signInWithGoogle()
            
            if isNewUser {
                // if new user, save to server (signup)
                let fullName = try await firebaseAuthService.getUserFullName()
                let parts = fullName.components(separatedBy: " ")
                self.firstName = parts[0]
                self.lastName = parts[1]
                
                do {
                    let firebaseUID = try await firebaseAuthService.getFirebaseUID()
                    try await serverService.saveUser(firstName: self.firstName, lastName: self.lastName, firebaseUID: firebaseUID)
                    print("User data posted successfully")
                    try await self.getUserFromServer()
                } catch {
                    self.errorMessage = "Error signing in with Google"
                    print("Error posting user data")
                    
                    // delete Firebase user
                    do {
                        try await firebaseAuthService.deleteFirebaseUser()
                        // account deleted
                        print("User deleted from Firebase")
                    }catch {
                        // an error happened
                        self.errorMessage = "Error signing in with Google"
                        print("Error deleting user from Firebase")
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
            print("Error signing in with Google")
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
