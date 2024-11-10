import Combine
import SwiftData
import SwiftUI

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
    
    @Published var firstNameField: String = ""
    @Published var lastNameField: String = ""
    @Published var birthDateField: Date?
    @Published var genderField: Gender = .notSpecified
    @Published var cityField: String?
    @Published var streetNameField: String?
    @Published var houseNumberField: Int?
    @Published var zipCodeField: Int?
    @Published var hasModified: Bool = false
    @Published var initializationPhase: Bool = true
        
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // must be done before view load
        // in order not to show the submit button
        getUserData()
    }
    
    func getUserData() {
        do {
            let users = try modelContext.fetch(FetchDescriptor<User>())
            if let user = users.first {
                firstNameField = user.firstName
                lastNameField = user.lastName
                birthDateField = user.birthDate
                genderField = Gender(from: user.gender)
                cityField = user.city
                streetNameField = user.streetName
                houseNumberField = user.houseNumber
                zipCodeField = user.zipCode
                
                initializationPhase = false
                hasModified = false
            }
        }catch {
            // TODO
        }
    }
    
    func saveModifications() {
        do {
            let users = try modelContext.fetch(FetchDescriptor<User>())
            
            // hide sumbit button
            hasModified = false
            
            // save to server and SwiftData
            if let user = users.first {
                let userID = user.userID!
                
                let baseURL = NetworkManager.shared.getBaseURL()
                guard let url = URL(string: "\(baseURL)/users/\(userID)") else {
                    print("Invalid URL for posting user data to DB")
                    return
                }
                
                var zipCodeInt = nil as Int?
                if let zipCodeString = zipCodeField {
                    zipCodeInt = Int(zipCodeString)
                }
                
                var houseNumberInt = nil as Int?
                if let houseNumberString = houseNumberField {
                    houseNumberInt = Int(houseNumberString)
                }
                
                let modifiedUser = User (
                    userID: userID,
                    firstName: firstNameField,
                    lastName: lastNameField,
                    birthDate: birthDateField,
                    gender: genderField.asString(),
                    firebaseUID: user.firebaseUID,
                    zipCode: zipCodeInt,
                    streetName: streetNameField,
                    houseNumber: houseNumberInt,
                    city: cityField
                )
                
                // JSON encoding
                guard let body = try? JSONEncoder().encode(modifiedUser) else {
                    print("Error encoding user data for PUT")
                    return
                }

                
                // PUT request
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                    }, receiveValue: { user in
                        self.updateUser(newUser: user)
                        self.getUserData()
                    })
                    .store(in: &cancellables)
            }
        }catch {
            
        }
    }
    
    func updateUser(newUser: User) {
        var users: [User]
        do {
            users = try modelContext.fetch(FetchDescriptor<User>())
            if let oldUser = users.first {
                do {
                    modelContext.delete(oldUser)
                    modelContext.insert(newUser)
                    try modelContext.save()
                } catch {
                    print("Error while updating user in SwiftData")
                    
                    // TODO
                }
            }
        }catch {
            print("Error while updating user in SwiftData")
            
            
            // TODO
        }
    }
    
    func logout(user: User) {
        modelContext.delete(user)
        
        do {
            try modelContext.save()
            print("User successfully logged out and removed from SwiftData")
        } catch {
            print("Error while saving context after logout: \(error)")
        }
    }
}
