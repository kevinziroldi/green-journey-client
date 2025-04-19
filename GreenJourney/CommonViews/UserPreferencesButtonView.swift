import SwiftUI

struct UserPreferencesButtonView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    @Binding var isPresenting: Bool
    
    var body: some View {
        Button(action: {
            if !isPresenting {
                isPresenting = true
                navigationPath.append(NavigationDestination.UserPreferencesView)
            }
        }) {
            Image(systemName: "person")
                .font(.title)
                .foregroundStyle(AppColors.mainColor)
        }
        .accessibilityIdentifier("userPreferencesButton")
    }
}
