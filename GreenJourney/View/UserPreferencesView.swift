import Combine
import FirebaseAuth
import SwiftData
import SwiftUI

struct UserPreferencesView : View {
    @Environment(\.modelContext) private var modelContext
    @Query var users: [User]
    let email: String = Auth.auth().currentUser?.email ?? ""
    @State private var cancellables = Set<AnyCancellable>()

    @State private var firstNameField: String = ""
    @State private var lastNameField: String = ""
    @State private var birthDateField: String = ""
    @State private var genderField: String = ""
    @State private var cityField: String = ""
    @State private var streetNameField: String = ""
    @State private var houseNumberField: String = ""
    @State private var zipCodeField: String = ""
    @State private var hasModified: Bool = false
    
    var body: some View {
        if let user = users.first {
            VStack() {
                HStack {
                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }.padding()
                
                Text("Hi, \(user.firstName) \(user.lastName)")
                    .font(.title2)
                    .padding()
                
                // email and password
                VStack(spacing: 8) {
                    Text("Email: \(email)")
                        .font(.body)
                    Button("Modify Password") {
                        // TODO
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                Text("Do you want to get better predictions about your future travels? Complete your profile!")
                
                VStack() {
                    TextField("First Name", text: $firstNameField, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Last Name", text: $lastNameField, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Birth Date", text: $birthDateField, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Gender", text: $genderField, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("City", text: $cityField, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Street name", text: $streetNameField, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("House number", text: $houseNumberField, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Zip code", text: $zipCodeField, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                .cornerRadius(15)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                if hasModified {
                    Button(action: saveModifications) {
                        Text("Save Modifications")
                    }
                }

                // logout button
                Button("Logout") {
                    logout(user: user)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .onAppear() {
                getUserData()
                if let user = users.first {
                    printUser(user: user)
                }
            }
        } else {
            LoginView(modelContext: modelContext)
        }
    }
    
    func printUser(user: User) {
        print(user.userID ?? -1)
        print(user.firstName)
        print(user.lastName)
        print(user.birthDate ?? "Nothing")
        print(user.gender ?? "Nothing")
        print(user.firebaseUID)
        print(user.zipCode ?? "Nothing")
        print(user.streetName ?? "Nothing")
        print(user.houseNumber ?? "Nothing")
        print(user.city ?? "Nothing")
    }
    
    
    private func getUserData() {
        if let user = users.first {
            firstNameField = user.firstName
            lastNameField = user.lastName
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = user.birthDate {
                birthDateField = dateFormatter.string(from:date)
            }
            genderField = user.gender ?? ""
            cityField = user.city ?? ""
            streetNameField = user.streetName ?? ""
            if let houseNumberInt = user.houseNumber {
                houseNumberField = String(houseNumberInt)
            }
            if let zipCodeInt = user.zipCode {
                zipCodeField = String(zipCodeInt)
            }
        }
    }
    
    private func saveModifications() {
        hasModified = false
        
        if let user = users.first {
            let userID = user.userID!
            
            print("DATA TO SAVE: ")
            print(user.userID!)
            print(firstNameField)
            print(lastNameField)
            print(birthDateField)
            print(genderField)
            print(user.firebaseUID)
            print(zipCodeField)
            print(streetNameField)
            print(houseNumberField)
            print(cityField)
            
            let baseURL = NetworkManager.shared.getBaseURL()
            guard let url = URL(string: "\(baseURL)/users/\(userID)") else {
                print("Invalid URL for posting user data to DB")
                return
            }
            
            let zipCodeInt = Int(zipCodeField) ?? user.zipCode
            let houseNumberInt = Int(houseNumberField) ?? user.houseNumber
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateDate = dateFormatter.date(from: birthDateField) ?? user.birthDate
            
            var actualGender = user.gender
            if genderField == "male" || genderField == "female" || genderField == "other" {
                actualGender = genderField
            }
            
            let modifiedUser = User (
                userID: userID,
                firstName: firstNameField,
                lastName: lastNameField,
                birthDate: dateDate,
                gender: actualGender,
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
                .decode(type: [User].self, decoder: decoder)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("User data posted successfully.")
                    case .failure(let error):
                        print("Error posting user data: \(error.localizedDescription)")
                    }
                }, receiveValue: { users in
                    if let user = users.first {
                        updateUser(newUser: user)
                        getUserData()
                    }
                })
                .store(in: &cancellables)
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
                    // TODO
                }
            }
        }catch {
            // TODO
        }
    }
    
    private func logout(user: User) {
        modelContext.delete(user)
        
        do {
            try modelContext.save()
            print("User successfully logged out and removed from SwiftData")
        } catch {
            print("Error while saving context after logout: \(error)")
        }
    }
}
