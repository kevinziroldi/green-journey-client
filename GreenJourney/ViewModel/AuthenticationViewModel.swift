import FirebaseAuth
import SwiftUI
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var errorMessage: String?
    @Published var resendEmail: String?
    @Published var isLogged: Bool = false
    @Published var userId: Int?
    @Published var emailVerified: Bool = false
    private var cancellables = Set<AnyCancellable>()


    
    func login() {
        // input check and validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Insert email and password."
            return
        }
        // Firebase call
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.errorMessage = error.localizedDescription
            } else {
                if let result = result {
                    // if login is ok, update isLogged
                    strongSelf.errorMessage = nil
                }
                strongSelf.isLogged = true
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
                        self.addUser(uid: result.user.uid)
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
                    self.emailVerified = true
                } else {
                    self.errorMessage = "email has not yet been verified"
                    print("Email not verified.")
                }
            })
    }
    
    private func addUser(uid: String) {
        let baseURL = NetworkManager.shared.getBaseURL()
        guard let url = URL(string: "\(baseURL)/users") else {
            print("Invalid URL for posting user data to DB")
            return
        }
        
        // creation of JSON body
        let body: [String: Any] = [
            "FirstName": self.firstName,
            "LastName": self.lastName,
            "FirebaseUID": uid
        ]
        
        // JSON encoding
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Error serializing JSON")
            return
        }
        
        // POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
 
        URLSession.shared.dataTaskPublisher(for: request)
            .retry(2)
            .tryMap { result -> Void in
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
                }
            }, receiveValue: { _ in
            })
            .store(in: &cancellables)
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
                if (additionalUserInfo.isNewUser) {
                    let fullName = firebaseUser.displayName
                    let parts = fullName?.components(separatedBy: " ")
                    self.firstName = parts![0]
                    self.lastName = parts![1]
                    addUser(uid: firebaseUser.uid)
                }
            }
            
            
            //TODO do something with this user
            DispatchQueue.main.async {
                self.isLogged = true
            }
            return true
        }
        catch {
            print(error.localizedDescription)
            return false
        }
    }
}
