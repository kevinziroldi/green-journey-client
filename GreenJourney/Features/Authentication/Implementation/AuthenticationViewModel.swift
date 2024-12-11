import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import SwiftData
import SwiftUI

class AuthenticationViewModel: ObservableObject {
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
    private var cancellables = Set<AnyCancellable>()
    //swift data model context
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.isLogged = false
    }
    
    // TODO remove
    /*
    func add(_ a: Int, _ b: Int) -> Int {
        return a+b
    }
    */
    
    func login() {
        // input check and validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Insert email and password."
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.errorMessage = error.localizedDescription
            } else {
                if let firebaseUser = result?.user {
                    strongSelf.emailVerified = firebaseUser.isEmailVerified
                    
                    if firebaseUser.isEmailVerified == true {
                        firebaseUser.getIDToken { [weak self] token, error in
                            guard let strongSelf = self else { return }
                            if let error = error {
                                print("Failed to fetch token: \(error.localizedDescription)")
                                strongSelf.errorMessage = "Error during authentication"
                            } else if let token = token {
                                strongSelf.errorMessage = nil
                                strongSelf.getUserFromServer(firebaseToken: token)
                            }
                        }
                    } else {
                        strongSelf.isEmailVerificationActiveLogin = true
                    }
                } else {
                    strongSelf.errorMessage = "Error during authentication"
                }
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
        guard(!email.isEmpty) else {
            errorMessage = "Insert email"
            return
        }
        errorMessage = nil
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Error in sending email for password recovery: \(error.localizedDescription)")
                strongSelf.errorMessage = "Error in sending email for password recovery"
                strongSelf.resendEmail = nil
            }
            else {
                print("Email for password reset sent")
                strongSelf.resendEmail = "Email sent, check your inbox"
            }
        }
    }
    
    func signUp() {
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
        else {
            // Firebase call, create account
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    print(error.localizedDescription)
                    strongSelf.errorMessage = "Error creating account"
                    return
                } else {
                    if let result = result {
                        // if login is ok
                        
                        result.user.getIDToken { [weak self] token, error in
                            guard let strongSelf = self else { return }
                            if let error = error {
                                print("Error getting token: \(error.localizedDescription)")
                                strongSelf.errorMessage = "Error creating account"
                            } else if let token = token {
                                print("Token retrieved")
                                strongSelf.saveUserToServer(firebaseUID: result.user.uid, firebaseToken: token)
                                    .sink(receiveCompletion: { completion in
                                        switch completion {
                                        case .finished:
                                            print("User data posted successfully.")
                                        case .failure(let error):
                                            print("Error posting user data: \(error.localizedDescription)")
                                            let user = Auth.auth().currentUser
                                            user?.delete { error in
                                                if let error = error {
                                                    // error happened
                                                    print("Error deleting user from Firebase: \(error.localizedDescription)")
                                                } else {
                                                    // account deleted
                                                    print("User deleted from firebase")
                                                }
                                            }
                                        }
                                    }, receiveValue: {
                                        strongSelf.errorMessage = nil
                                        strongSelf.sendEmailVerification()
                                        strongSelf.isEmailVerificationActiveSignup = true
                                    })
                                    .store(in: &strongSelf.cancellables)
                            }
                        }
                    } else {
                        strongSelf.errorMessage = "Error creating account"
                    }
                }
            }
        }
    }
    
    func sendEmailVerification() {
        Auth.auth().currentUser?.sendEmailVerification { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.errorMessage = "Error sending email verification"
            if let error = error {
                print("error while sending email verification: " + error.localizedDescription)
                
            }
        }
    }
    
    func verifyEmail() {
        Auth.auth().currentUser?.reload(completion: { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Error reloading user: \(error.localizedDescription)")
                strongSelf.errorMessage = "Error verifying email"
                return
            }
            if Auth.auth().currentUser?.isEmailVerified == true {
                print("Email verified")
                strongSelf.errorMessage = nil
                strongSelf.emailVerified = true
                strongSelf.isEmailVerificationActiveLogin = false
                strongSelf.isEmailVerificationActiveSignup = false
                
                // save user to swift data
                if let firebaseUser = Auth.auth().currentUser {
                    firebaseUser.getIDToken { token, error in
                        if let error = error {
                            print(error.localizedDescription)
                            strongSelf.errorMessage = "Error verifying email"
                            return
                        } else if let token = token {
                            strongSelf.getUserFromServer(firebaseToken: token)
                        }
                    }
                }else {
                    strongSelf.errorMessage = "Error verifying email"
                    print("Missing firebaseUID")
                    return
                }
            } else {
                strongSelf.errorMessage = "Email has not been verified yet"
                print("Email not verified")
            }
        })
    }
    
    private func saveUserToServer(firebaseUID: String, firebaseToken: String) -> AnyPublisher<Void, Error>{
        let baseURL = NetworkHandler.shared.getBaseURL()
        guard let url = URL(string: "\(baseURL)/users/user") else {
            print("Invalid URL for posting user data to DB")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let user = User(firstName: self.firstName, lastName: self.lastName, firebaseUID: firebaseUID, scoreShortDistance: 0, scoreLongDistance: 0)
        // JSON encoding
        guard let body = try? JSONEncoder().encode(user) else {
            print("error in encoding user data")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        
        // POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .retry(2)
            .tryMap {
                result -> Void in
                // check status of response
                guard let httpResponse = result.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func getUserFromServer(firebaseToken: String) {
        let baseURL = NetworkHandler.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/users/user") else {
            print("Invalid URL used to retrieve user from DB")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        URLSession.shared.dataTaskPublisher(for: request)
            .retry(2)
            .tryMap {
                result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: User.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching user: \(error.localizedDescription)")
                    return
                }
            }, receiveValue: { [weak self] user in
                guard let strongSelf = self else { return }
                strongSelf.saveUserToSwiftData(serverUser: user)
            })
            .store(in: &cancellables)
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
    
    func resetParameters() {
        email = ""
        password = ""
        repeatPassword = ""
        firstName = ""
        lastName = ""
        errorMessage = nil
        resendEmail = nil
        isLogged = false
        isEmailVerificationActiveLogin = false
        isEmailVerificationActiveSignup = false
        emailVerified = false
    }
}

extension AuthenticationViewModel {
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            self.errorMessage = "Error signing in with Google"
            print("There is no root view controller")
            return false
        }
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                self.errorMessage = "Error signing in with Google"
                print("ID token Missing")
                return false
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            if let additionalUserInfo = result.additionalUserInfo {
                DispatchQueue.main.async {
                    firebaseUser.getIDToken { [weak self] token, error in
                        guard let strongSelf = self else { return }
                        if let error = error {
                            strongSelf.errorMessage = "Error signing in with Google"
                            print("Failed to fetch token: \(error.localizedDescription)")
                        } else if let token = token {
                            if (additionalUserInfo.isNewUser) {
                                let fullName = firebaseUser.displayName
                                let parts = fullName?.components(separatedBy: " ")
                                strongSelf.firstName = parts![0]
                                strongSelf.lastName = parts![1]
                                
                                strongSelf.saveUserToServer(firebaseUID: firebaseUser.uid, firebaseToken: token)
                                    .sink(receiveCompletion: { completion in
                                        
                                        switch completion {
                                        case .finished:
                                            print("User data posted successfully.")
                                            strongSelf.getUserFromServer(firebaseToken: token)
                                        case .failure(let error):
                                            strongSelf.errorMessage = "Error signing in with Google"
                                            print("Error posting user data: \(error.localizedDescription)")
                                            let user = Auth.auth().currentUser
                                            user?.delete { error in
                                                if let error = error {
                                                    // an error happened
                                                    strongSelf.errorMessage = "Error signing in with Google"
                                                    print("Error deleting user from Firebase: \(error.localizedDescription)")
                                                } else {
                                                    // account deleted
                                                    print("User deleted from Firebase")
                                                }
                                            }
                                        }
                                    }, receiveValue: {})
                                    .store(in: &strongSelf.cancellables)
                            }
                            else {
                                strongSelf.getUserFromServer(firebaseToken: token)
                            }
                            
                        }
                    }
                    
                }
            }
        }
        catch {
            print(error.localizedDescription)
            return false
        }
        return true
    }
}
