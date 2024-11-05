import FirebaseAuth
import SwiftUI
import Combine

class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var errorMessage: String?
    @Published var emailVerified: Bool = false
    private var cancellables = Set<AnyCancellable>()

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
    
    func addUser(uid: String) {
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


