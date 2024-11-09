import FirebaseAuth
import SwiftData
import SwiftUI

struct UserPreferencesView : View {
    @Environment(\.modelContext) private var modelContext
    @Query var users: [User]
    private let email: String = Auth.auth().currentUser?.email ?? "Not available"
    
    @State private var firstName: String = "Pippo"
    @State private var lastName: String = ""
    @State private var birthDate: String = ""
    @State private var gender: String = ""
    @State private var city: String = ""
    @State private var streetName: String = ""
    @State private var houseNumber: String = ""
    @State private var zipCode: String = ""
    
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
                    TextField("First Name", text: $firstName, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Last Name", text: $lastName, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Birth Date", text: $birthDate, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Gender", text: $gender, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("City", text: $city, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Street name", text: $streetName, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("House number", text: $houseNumber, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Zip code", text: $zipCode, onEditingChanged: { _ in self.hasModified = true })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                .cornerRadius(15)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            if hasModified {
                Button(action: saveModifications) {
                    Text("Save Modifications")
                }
            }

            // logout button
            Button("Logout") {
                logout(user: user)
            }
        } else {
            LoginView(modelContext: modelContext)
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
    
    private func saveModifications() {
        
    }
}

#Preview {
    UserPreferencesView()
}
