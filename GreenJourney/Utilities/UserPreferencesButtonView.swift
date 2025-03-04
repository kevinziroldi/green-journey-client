import SwiftUI

struct UserPreferencesButtonView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    var serverService: ServerServiceProtocol
    var firebaseAuthService: FirebaseAuthServiceProtocol
    
    var body: some View {
        NavigationLink(destination: UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)) {
            Image(systemName: "person")
                .font(.title)
                .foregroundStyle(AppColors.mainGreen)
        }
        .accessibilityIdentifier("userPreferencesButton")
    }
}
