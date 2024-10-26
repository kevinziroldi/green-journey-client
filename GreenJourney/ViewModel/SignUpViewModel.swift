//
//  SignUpViewModel.swift
//  GreenJourney
//
//  Created by matteo volpari on 26/10/24.
//

import FirebaseAuth
import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    @Published var errorMessage: String?
    @AppStorage("isLoggedIn") var isLoggedIn = false
    var loggedUser: User?
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !repeatPassword.isEmpty else {
            errorMessage = "Insert email and password."
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
                } else { if let result = result {
                        // if login is ok, update isLogged
                        self.loggedUser = User(firebaseUID: result.user.uid)
                        self.isLoggedIn = true
                        self.errorMessage = nil
                    }
                }
            }
        }
    }
}
