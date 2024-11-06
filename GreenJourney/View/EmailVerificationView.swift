import SwiftUI

struct EmailVerificationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    var body: some View {
        VStack {
            Spacer()
            Text("check your email box and verify your GreenJourney account")
            Spacer()
            Button ("Proceed"){
                viewModel.verifyEmail()
                }
            .fullScreenCover(isPresented: $viewModel.emailVerified) {
                MainView()
            }
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            Spacer()
        }
    }
}
