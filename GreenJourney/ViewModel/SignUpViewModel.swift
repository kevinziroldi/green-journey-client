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
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var errorMessage: String?
    
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
                        // if login is ok
                        self.errorMessage = nil
                    }
                    Auth.auth().currentUser?.sendEmailVerification { error in
                      print("error while sending email verification")
                    }
                }
            }
        }
    }
}
