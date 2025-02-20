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
        
            HStack {
                Text("""
We’ve sent a verification email to your inbox. Please check and verify your account. 
If you didn’t receive it, tap 'Resend Email'.
"""
                )
                .accessibilityIdentifier("emailSentText")
                
                Button ("resend email") {
                    Task {
                        await viewModel.sendEmailVerification()
                        viewModel.resendEmail = "email re-send correctly"
                    }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("resendEmailButton")
            }
            
            Button ("Proceed") {
                Task {
                    await viewModel.verifyEmail()
                }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("proceedButton")
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .accessibilityIdentifier("errorMessage")
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
