import SwiftUI

struct UserPreferencesButtonView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    var serverService: ServerServiceProtocol
    var firebaseAuthService: FirebaseAuthServiceProtocol
    
    var body: some View {
        Button (action: {
            navigationPath.append(NavigationDestination.UserPreferencesView)
        }) {
            Image(systemName: "person")
                .font(.title)
                .foregroundStyle(AppColors.mainColor)
        }
        .accessibilityIdentifier("userPreferencesButton")
    }
}
