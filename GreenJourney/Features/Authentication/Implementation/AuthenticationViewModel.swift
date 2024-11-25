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
    @Published var isLogged: Bool = false
    @Published var userID: Int?
    @Published var emailVerified: Bool = false
    @Published var isEmailVerificationActive: Bool = false
    private var cancellables = Set<AnyCancellable>()
    //swift data model context
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
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
                    if firebaseUser.isEmailVerified == true {
                        // Login riuscito, salva l'utente in SwiftData
                        strongSelf.getUserFromServer(firebaseUID: firebaseUser.uid)
                    }
                    else {
                        strongSelf.isEmailVerificationActive = true
                    }
                }
                strongSelf.errorMessage = nil
            }
        }
    }
    
    func resetPassword() {
        guard(!email.isEmpty) else {
            errorMessage = "insert email."
            return
        }
        errorMessage = nil
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("error in sending email for password recovery")
                self.errorMessage = error.localizedDescription
                self.resendEmail = nil
            }
            else {
                print("email for password reset sent")
                self.resendEmail = "email sent"
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
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    if let result = result {
                        // if login is ok
                        self.isEmailVerificationActive = true
                        self.saveUserToServer(uid: result.user.uid)
                        Auth.auth().currentUser?.sendEmailVerification { error in
                            if let error = error {
                                print("error while sending email verification: " + error.localizedDescription)
                            }
                        }
                        self.errorMessage = nil
                    }
                }
            }
        }
    }
    
    func verifyEmail() {
        Auth.auth().currentUser?.reload(completion: { (error) in
            if let error = error {
                print("Errore nel ricaricare l'utente: \(error.localizedDescription)")
                return
            }
            if Auth.auth().currentUser?.isEmailVerified == true {
                print("Email verified")
                self.errorMessage = nil
                
                // save user to swift data
                if let firebaseUID = Auth.auth().currentUser?.uid {
                    self.getUserFromServer(firebaseUID: firebaseUID)
                }else {
                    print("Missing firebase uid")
                    return
                }
                
                self.emailVerified = true
            } else {
                self.errorMessage = "email has not yet been verified"
                print("Email not verified.")
            }
        })
    }
    
    private func saveUserToServer(uid: String) {
        let baseURL = NetworkManager.shared.getBaseURL()
        guard let url = URL(string: "\(baseURL)/users") else {
            print("Invalid URL for posting user data to DB")
            return
        }
        
        let user = User(firstName: self.firstName, lastName: self.lastName, firebaseUID: uid, scoreShortDistance: 0, scoreLongDistance: 0)
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
    
    private func getUserFromServer(firebaseUID: String) {
        let baseURL = NetworkManager.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/users?uid=\(firebaseUID)") else {
            print("Invalid URL used to retrieve user from DB")
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        URLSession.shared.dataTaskPublisher(for: url)
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
                guard let strongSelf = self else { return }
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
                        self.saveUserToServer(uid: firebaseUser.uid)
                    }
                    // in any case, save to swift data
                    self.getUserFromServer(firebaseUID: firebaseUser.uid)
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
