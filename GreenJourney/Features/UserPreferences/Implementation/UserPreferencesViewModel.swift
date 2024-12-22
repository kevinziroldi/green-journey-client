import Combine
import SwiftData
import SwiftUI
import FirebaseAuth

enum Gender: String, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    case notSpecified = "not specified"
    
    init(from gender: String?) {
        if let genderString = gender {
            self =  Gender(rawValue: genderString.lowercased()) ?? .notSpecified
        }else {
            self = .notSpecified
        }
    }
    
    func asString() -> String? {
        if self == .male || self == .female || self == .other {
            return self.rawValue
        }else {
            return nil
        }
    }
}

class UserPreferencesViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    //swift data model context
    var modelContext: ModelContext
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var birthDate: Date?
    @Published var gender: Gender = .notSpecified
    @Published var city: String?
    @Published var streetName: String?
    @Published var houseNumber: Int?
    @Published var zipCode: Int?
    
    @Published var errorMessage: String?
        
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getUserData() {
        do {
            errorMessage = nil
            let users = try modelContext.fetch(FetchDescriptor<User>())
            if let user = users.first {
                DispatchQueue.main.async {
                    self.firstName = user.firstName
                    self.lastName = user.lastName
                    self.birthDate = user.birthDate
                    self.gender = Gender(from: user.gender)
                    self.city = user.city
                    self.streetName = user.streetName
                    self.houseNumber = user.houseNumber
                    self.zipCode = user.zipCode
                }
            }
        }catch {
            print("Error fetching user data")
        }
    }
    
    
    func saveModifications() {
        do {
            errorMessage = nil
            let users = try modelContext.fetch(FetchDescriptor<User>())
            
            // save to server and SwiftData
            if let user = users.first {
                let userID = user.userID!
                
                let baseURL = NetworkHandler.shared.getBaseURL()
                guard let url = URL(string: "\(baseURL)/users") else {
                    print("Invalid URL for posting user data to DB")
                    return
                }
                
                var zipCodeInt = nil as Int?
                if let zipCodeString = zipCode {
                    zipCodeInt = Int(zipCodeString)
                }
                
                var houseNumberInt = nil as Int?
                if let houseNumberString = houseNumber {
                    houseNumberInt = Int(houseNumberString)
                }
                if (city == "") {
                    city = nil
                }
                if (streetName == "") {
                    streetName = nil
                }
                
                
                let modifiedUser = User (
                    userID: userID,
                    firstName: firstName,
                    lastName: lastName,
                    birthDate: birthDate,
                    gender: gender.asString(),
                    firebaseUID: user.firebaseUID,
                    zipCode: zipCodeInt,
                    streetName: streetName,
                    houseNumber: houseNumberInt,
                    city: city,
                    scoreShortDistance: user.scoreShortDistance,
                    scoreLongDistance: user.scoreLongDistance
                )
                
                
                // JSON encoding
                guard let body = try? JSONEncoder().encode(modifiedUser) else {
                    print("Error encoding user data for PUT")
                    return
                }
                
                guard let firebaseUser = Auth.auth().currentUser else {
                    print("no current user in firebase")
                    return
                }
                firebaseUser.getIDToken { [weak self] token, error in
                    guard let strongSelf = self else { return }
                    if let error = error {
                        print("error retrieveing token: \(error.localizedDescription)")
                        return
                    } else if let firebaseToken = token {
                        if firebaseUser.uid != modifiedUser.firebaseUID {
                            print("modified user has different firebase uid")
                            return
                        }
                        // PUT request
                        var request = URLRequest(url: url)
                        request.httpMethod = "PUT"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
                        request.httpBody = body
                        
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
                            .sink(receiveCompletion: { completion in
                                switch completion {
                                case .finished:
                                    print("User data posted successfully.")
                                case .failure(let error):
                                    print("Error posting user data: \(error.localizedDescription)")
                                }
                            }, receiveValue: { [weak self] newUser in
                                guard let strongSelf = self else { return }
                                strongSelf.updateUser(newUser: newUser)
                                strongSelf.getUserData()
                            })
                            .store(in: &strongSelf.cancellables)
                    }
                    else {
                        print("error retrieving user token")
                    }
                }
            }
        }catch {
            errorMessage = "An error occurred during modification saving, retry later."
        }
    }
    
    func updateUser(newUser: User) {
        var users: [User]
        do {
            errorMessage = nil
            users = try modelContext.fetch(FetchDescriptor<User>())
            if let oldUser = users.first {
                do {
                    // update values
                    oldUser.firstName = newUser.firstName
                    oldUser.lastName = newUser.lastName
                    oldUser.birthDate = newUser.birthDate
                    oldUser.gender = newUser.gender
                    oldUser.city = newUser.city
                    oldUser.streetName = newUser.streetName
                    oldUser.houseNumber = newUser.houseNumber
                    oldUser.zipCode = newUser.zipCode
                    oldUser.scoreShortDistance = newUser.scoreShortDistance
                    oldUser.scoreLongDistance = newUser.scoreLongDistance
                    try modelContext.save()
                } catch {
                    print("Error while updating user in SwiftData")
                    
                    errorMessage = "An error occurred while updating user"
                }
            }
        }catch {
            print("Error while updating user in SwiftData")
            errorMessage = "An error occurred while updating user"
        }
    }
    
    func binding(for value: Binding<Int?>) -> Binding<String> {
            Binding<String>(
                get: {
                    if let unwrapped = value.wrappedValue {
                        return String(unwrapped)
                    } else {
                        return ""
                    }
                },
                set: { newValue in
                    if let intValue = Int(newValue) {
                        value.wrappedValue = intValue
                    } else {
                        value.wrappedValue = nil
                    }
                }
            )
        }
    
    func cancelModifications() {
        getUserData()
    }
}
