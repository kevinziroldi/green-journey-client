import SwiftData
import SwiftUI

struct UserPreferencesView : View {
    @Environment(\.modelContext) private var modelContext
    @Query var users: [User]
    
    var body: some View {
        if let user = users.first {
            Text("UserPreferencesView")
            Text("Hi " + user.firstName + " " + user.lastName)
            
            Button("Logout") {
                logout(user: user)
            }
            
        }else {
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
}
