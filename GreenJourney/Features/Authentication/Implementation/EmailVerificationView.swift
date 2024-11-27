import SwiftUI

struct EmailVerificationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Spacer()
            Text("check your email box and verify your GreenJourney account")
            Spacer()
            HStack {
                
                if let resendMessage = viewModel.resendEmail {
                    Text(resendMessage)
                }
                Button ("resend email") {
                    viewModel.sendEmailVerification()
                    viewModel.resendEmail = "email re-send correctly"
                }
            }
            Button ("Proceed"){
                viewModel.verifyEmail()
            }
            .fullScreenCover(isPresented: $viewModel.emailVerified) {
                MainView(modelContext: modelContext)
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
