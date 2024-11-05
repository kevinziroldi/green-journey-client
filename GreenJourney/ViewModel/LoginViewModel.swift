import FirebaseAuth
import SwiftUI
import FirebaseCore
import GoogleSignIn
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
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
            print (error)
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            // ...
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)

          // ...
        }
        }
        
        func signInWithApple() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
    }
}
