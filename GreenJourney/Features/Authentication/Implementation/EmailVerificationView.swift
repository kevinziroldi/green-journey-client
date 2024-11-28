import SwiftUI

struct EmailVerificationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Text("Email verification")
                .font(.largeTitle)
                .padding(.bottom, 32)
            Image("loginLogo")
                .resizable()
                .padding()
                .aspectRatio(contentMode: .fit)
            HStack {
                
                Text("""
We’ve sent a verification email to your inbox. Please check and verify your account. 
If you didn’t get it, tap 'Resend Email'.
"""
)
                Button ("resend email") {
                    viewModel.sendEmailVerification()
                    viewModel.resendEmail = "email re-send correctly"
                }
                .buttonStyle(.borderedProminent)
            }
            Button ("Proceed"){
                viewModel.verifyEmail()
            }
            .buttonStyle(.borderedProminent)
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
