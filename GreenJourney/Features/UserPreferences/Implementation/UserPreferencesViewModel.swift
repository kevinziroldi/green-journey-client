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
    //swift data model context
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var birthDate: Date?
    @Published var gender: Gender = .notSpecified
    @Published var city: String?
    @Published var streetName: String?
    @Published var houseNumber: Int?
    @Published var zipCode: Int?
    
    @Published var errorMessage: String?
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol) {
        self.modelContext = modelContext
        self.serverService = serverService
    }
    
    @MainActor
    func getUserData() {
        do {
            self.errorMessage = nil
            let users = try modelContext.fetch(FetchDescriptor<User>())
            if let user = users.first {
                self.firstName = user.firstName
                self.lastName = user.lastName
                self.birthDate = user.birthDate
                self.gender = Gender(from: user.gender)
                self.city = user.city
                self.streetName = user.streetName
                self.houseNumber = user.houseNumber
                self.zipCode = user.zipCode
            } else {
                self.errorMessage = "An error occurred"
            }
        }catch {
            print("Error fetching user data")
            self.errorMessage = "An error occurred"
        }
    }
    
    @MainActor
    func saveModifications() async {
        self.errorMessage = nil
        
        // get current user
        let users: [User]
        do {
            users = try modelContext.fetch(FetchDescriptor<User>())
        }catch {
            print("Error fetching user from SwiftData")
            self.errorMessage = "An error occurred"
            return
        }
        guard let user = users.first else {
            print("No user present")
            self.errorMessage = "An error occurred"
            return
        }
        guard let userID = user.userID else {
            print("User has no user id")
            self.errorMessage = "An error occurred"
            return
        }
        
        // build modified user
        if (self.city == "") {
            self.city = nil
        }
        if (self.streetName == "") {
            self.streetName = nil
        }
        let modifiedUser = User (
            userID: userID,
            firstName: self.firstName,
            lastName: self.lastName,
            birthDate: self.birthDate,
            gender: self.gender.asString(),
            firebaseUID: user.firebaseUID,
            zipCode: self.zipCode,
            streetName: self.streetName,
            houseNumber: self.houseNumber,
            city: self.city,
            scoreShortDistance: user.scoreShortDistance,
            scoreLongDistance: user.scoreLongDistance
        )
        
        // update user on server
        do {
            let returnedUser = try await serverService.modifyUser(modifiedUser: modifiedUser)
            self.updateUserInSwiftData(newUser: returnedUser)
            self.getUserData()
        }catch {
            self.errorMessage = "Error saving modifications"
            print("Error saving modifications on server: \(error.localizedDescription)")
            return
        }
    }
    
    private func updateUserInSwiftData(newUser: User) {
        var users: [User]
        do {
            self.errorMessage = nil
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
                    self.errorMessage = "An error occurred while updating user"
                }
            }
        }catch {
            print("Error while updating user in SwiftData")
            self.errorMessage = "An error occurred while updating user"
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
    
    @MainActor
    func cancelModifications() {
        getUserData()
    }
}
