import FirebaseAuth
import SwiftUI
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var resendEmail: String?
    @Published var isLogged: Bool = false
    @Published var userId: Int?
    
    func login() {
        // input chack and validation
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
}


extension LoginViewModel {
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
