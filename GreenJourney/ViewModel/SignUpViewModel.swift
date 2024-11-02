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
    @Published var emailVerified: Bool = false
    
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
                } else {
                    if let result = result {
                        // if login is ok
                        Auth.auth().currentUser?.sendEmailVerification { error in
                            if let error = error {
                                print("error while sending email verification")
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
}
