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
    //swift data model context
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
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
        
        // TODO mock or not
        self.serverService = ServerService()
        self.firebaseAuthService = FirebaseAuthService()
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
        Task { @MainActor in
            errorMessage = nil
            
            // get current user
            let users = try modelContext.fetch(FetchDescriptor<User>())
            guard let user = users.first else {
                print("No user present")
                return
            }
            guard let userID = user.userID else {
                print("User has no user id")
                return
            }
            
            // build modified user
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
            
            // update user on server
            guard let firebaseUser = Auth.auth().currentUser else {
                print("No current user in firebase")
                return
            }
            do {
                let firebaseToken = try await firebaseAuthService.getFirebaseToken(firebaseUser: firebaseUser)
                let returnedUser = try await serverService.modifyUser(firebaseToken: firebaseToken, modifiedUser: modifiedUser)
                self.updateUserInSwiftData(newUser: returnedUser)
                self.getUserData()
            }catch {
                self.errorMessage = "Error saving modifications"
                print("Error saving modifications on server: \(error.localizedDescription)")
                return
            }
        }
    }
        
    func updateUserInSwiftData(newUser: User) {
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
