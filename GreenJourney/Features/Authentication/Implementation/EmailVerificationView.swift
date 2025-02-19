import SwiftUI

struct EmailVerificationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            Text("Email verification")
                .font(.largeTitle)
                .padding(.bottom, 32)
                .accessibilityIdentifier("emailVerificationTitle")
            
            Image("loginLogo")
                .resizable()
                .padding()
                .aspectRatio(contentMode: .fit)
            HStack {
                Text("""
We’ve sent a verification email to your inbox. Please check and verify your account. 
If you didn’t get it, tap 'Resend Email'.
""")
                Button ("resend email") {
                    Task {
                        await viewModel.sendEmailVerification()
                        viewModel.resendEmail = "email re-send correctly"
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            Button ("Proceed") {
                Task {
                    await viewModel.verifyEmail()
                }
            }
            .buttonStyle(.borderedProminent)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            Spacer()
        }
        .onChange(of: viewModel.emailVerified, {
            if viewModel.emailVerified {
                navigationPath = NavigationPath()
            }
        })
    }
}
