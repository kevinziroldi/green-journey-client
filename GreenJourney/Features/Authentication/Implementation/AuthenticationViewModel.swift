import Combine
import FirebaseCore
import FirebaseAuth
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
    @Published var isEmailVerificationActive: Bool = false
    private var cancellables = Set<AnyCancellable>()
    //swift data model context
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.isLogged = false
    }
    
    func login() {
        // input check and validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Insert email and password."
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else { print("ERROR"); return }
            if let error = error {
                strongSelf.errorMessage = error.localizedDescription
            } else {
                if let firebaseUser = result?.user {
                    if firebaseUser.isEmailVerified == true {
                        firebaseUser.getIDToken { [weak self] token, error in
                            guard let strongSelf = self else {print("ERROR"); return }
                            if let error = error {
                                strongSelf.errorMessage = "Failed to fetch token: \(error.localizedDescription)"
                            } else if let token = token {
                                strongSelf.getUserFromServer(firebaseToken: token)
                            }
                        }
                    }
                    else {
                        strongSelf.isEmailVerificationActive = true
                    }
                }
                strongSelf.errorMessage = nil
            }
        }
    }
    
    func logout(user: User) {
        modelContext.delete(user)
        
        do {
            try modelContext.save()
            print("User successfully logged out and removed from SwiftData")
        } catch {
            print("Error while saving context after logout: \(error)")
        }
        
        self.isLogged = false
    }
    
    
    func resetPassword() {
        guard(!email.isEmpty) else {
            errorMessage = "insert email."
            return
        }
        errorMessage = nil
        Auth.auth().sendPasswordReset(withEmail: email) {[weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                print("error in sending email for password recovery")
                strongSelf.errorMessage = error.localizedDescription
                strongSelf.resendEmail = nil
            }
            else {
                print("email for password reset sent")
                strongSelf.resendEmail = "email sent"
            }
        }
    }
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !repeatPassword.isEmpty else {
            errorMessage = "Insert email and password."
            return
        }
        guard !firstName.isEmpty, !lastName.isEmpty else {
            errorMessage = "insert first name and last name."
            return
        }
        if (password != repeatPassword) {
            errorMessage = "passwords do not match"
            return
        }
        else {
            //Firebase call, create account
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    strongSelf.errorMessage = error.localizedDescription
                } else {
                    if let result = result {
                        // if login is ok
                        strongSelf.isEmailVerificationActive = true
                        
                        result.user.getIDToken { token, error in
                            if let error = error {
                                print("Error getting token: \(error.localizedDescription)")
                            } else if let token = token {
                                print("Token retrieved: \(token)")
                                // Puoi utilizzare il token per fare chiamate al server
                                strongSelf.saveUserToServer(firebaseUID: result.user.uid, firebaseToken: token)
                            }
                        }
                        strongSelf.sendEmailVerification()
                        
                        strongSelf.errorMessage = nil
                    }
                }
            }
        }
    }
    
    func sendEmailVerification() {
        Auth.auth().currentUser?.sendEmailVerification { error in
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
                return
            }
            if Auth.auth().currentUser?.isEmailVerified == true {
                print("Email verified")
                strongSelf.errorMessage = nil
                
                // save user to swift data
                if let firebaseUser = Auth.auth().currentUser {
                    firebaseUser.getIDToken { token, error in
                        if let error = error {
                            strongSelf.errorMessage = "Failed to fetch token: \(error.localizedDescription)"
                        } else if let token = token {
                            strongSelf.getUserFromServer(firebaseToken: token)
                        }
                    }
                }else {
                    print("Missing firebase uid")
                    return
                }
                
                strongSelf.emailVerified = true
                strongSelf.isEmailVerificationActive = false
            } else {
                strongSelf.errorMessage = "email has not yet been verified"
                print("Email not verified.")
            }
        })
    }
    
    private func saveUserToServer(firebaseUID: String, firebaseToken: String) {
        let baseURL = NetworkManager.shared.getBaseURL()
        guard let url = URL(string: "\(baseURL)/users/user") else {
            print("Invalid URL for posting user data to DB")
            return
        }
        
        let user = User(firstName: self.firstName, lastName: self.lastName, firebaseUID: firebaseUID, scoreShortDistance: 0, scoreLongDistance: 0)
        // JSON encoding
        guard let body = try? JSONEncoder().encode(user) else {
            print("error in encoding user data")
            return
        }
        print("body: " , String(data: body, encoding: .utf8)!)
        
        
        // POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
       
        URLSession.shared.dataTaskPublisher(for: request)
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
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("User data posted successfully.")
                case .failure(let error):
                    print("Error posting user data: \(error.localizedDescription)")
                    let user = Auth.auth().currentUser
                    user?.delete { error in
                      if let error = error {
                        // An error happened.
                          print("Error deleting user from Firebase: \(error.localizedDescription)")
                      } else {
                        // Account deleted.
                          print("User deleted from firebase")
                      }
                    }
                }
            }, receiveValue: { _ in
            })
            .store(in: &cancellables)
    }
    
    private func getUserFromServer(firebaseToken: String) {
        let baseURL = NetworkManager.shared.getBaseURL()
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
                }
            }, receiveValue: { [weak self] user in
                guard let strongSelf = self else { print("ERROR"); return }
                strongSelf.saveUserToSwiftData(serverUser: user)
                strongSelf.isLogged = true
            })
            .store(in: &cancellables)
    }
    
    private func saveUserToSwiftData(serverUser: User?) {
        if let user = serverUser {
            // add user to context
            modelContext.insert(user)
            
            // save user in SwiftData
            do {
                try modelContext.save()
                print("Saved user with firebaseuid " + user.firebaseUID + "in swift data")
            } catch {
                print("Error while saving user to SwiftData: \(error)")
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
    }
}

extension AuthenticationViewModel {
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("no client ID found in Firebase")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            print("there is no root view controller")
            return false
        }
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                print("ID token Missing")
                return false
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
        
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            if let additionalUserInfo = result.additionalUserInfo {
                DispatchQueue.main.async {
                    if (additionalUserInfo.isNewUser) {
                        let fullName = firebaseUser.displayName
                        let parts = fullName?.components(separatedBy: " ")
                        self.firstName = parts![0]
                        self.lastName = parts![1]
                        
                        firebaseUser.getIDToken { token, error in
                            if let error = error {
                                self.errorMessage = "Failed to fetch token: \(error.localizedDescription)"
                            } else if let token = token {
                                // Passa il token alla funzione
                                self.saveUserToServer(firebaseUID: firebaseUser.uid, firebaseToken: token)
                            }
                        }
                    }
                    // in any case, save to swift data
                    firebaseUser.getIDToken { [weak self] token, error in
                        guard let strongSelf = self else { return }
                        if let error = error {
                            strongSelf.errorMessage = "Failed to fetch token: \(error.localizedDescription)"
                        } else if let token = token {
                            // Passa il token alla funzione
                            strongSelf.getUserFromServer(firebaseToken: token)
                        }
                    }
                }
            }
            
            return true
        }
        catch {
            print(error.localizedDescription)
            return false
        }
    }
}
