import SwiftUI

struct EmailVerificationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            
            Image("login_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, 50)
            
            Text("Verify your email")
                .font(.system(size: 32).bold())
                .padding(.horizontal)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("emailVerificationTitle")
            
            VStack {
                Text("Please, Check your inbox and follow the verification link.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Once verified, return here to continue.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("emailSentText")
            }
            .padding(.top)
            .padding(.horizontal)
            .font(.title3)
            .fontWeight(.light)
            
            HStack {
                Text("Haven't received any email?")
                    .fontWeight(.thin)
                Button (action: {
                    Task {
                        await viewModel.sendEmailVerification()
                        withAnimation() {
                            viewModel.resendEmail = "email re-send correctly"
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation() {
                            viewModel.resendEmail = nil
                        }
                    }
                }) {
                    Text("Resend email")
                        .font(.headline)
                        .underline()
                }
                .accessibilityIdentifier("resendEmailButton")
            }
            .padding(.top)
            
            if let resendMessage = viewModel.resendEmail {
                Text(resendMessage)
                    .padding(.top, 15)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .accessibilityIdentifier("emailSentMessage")
            }
            
            Spacer()
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .accessibilityIdentifier("errorMessage")
            }
            
            Button (action: {
                Task {
                    await viewModel.verifyEmail()
                }
            }) {
                Text("Proceed")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("proceedButton")
            
            
            
        }
        .padding(.horizontal)
        .onChange(of: viewModel.emailVerified, {
            if viewModel.emailVerified {
                navigationPath = NavigationPath()
            }
        })
    }
}
