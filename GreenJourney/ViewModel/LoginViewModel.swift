//
//  LoginViewModel.swift
//  GreenJourney
//
//  Created by matteo volpari on 25/10/24.
//

import FirebaseAuth
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @AppStorage("isLoggedIn") var isLoggedIn = false
    var loggedUser: User?
    
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
            } else { if let result = result {
                    // if login is ok, update isLogged
                    strongSelf.loggedUser = User(firebaseUID: result.user.uid)
                    strongSelf.isLoggedIn = true
                    strongSelf.errorMessage = nil
                }
            }
        }
    }
}
