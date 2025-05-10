import SwiftUI

struct EmailVerificationView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var viewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    @State var remainingSeconds: Int = 60
    @State var resendAvailable: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                
                VStack {
                    Image("login_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, 50)
                        .frame(maxWidth: 500)
                    
                    Text("Verify your email")
                        .font(.system(size: 32).bold())
                        .padding(.horizontal)
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("emailVerificationTitle")
                    
                    VStack {
                        Text("Please, check your inbox and follow the verification link.")
                        Text("Once verified, return here to continue.")
                            .accessibilityIdentifier("emailSentText")
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    .font(.title3)
                    .fontWeight(.light)
                    
                    HStack {
                        Text("Haven't received any email?")
                            .fontWeight(.thin)
                        Button(action: {
                            Task {
                                await viewModel.sendEmailVerification()
                                resendAvailable = false
                                remainingSeconds = 60
                                withAnimation() {
                                    viewModel.resendEmail = "We sent you a new email, check your inbox!"
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
                        .disabled(!resendAvailable)
                        .accessibilityIdentifier("resendEmailButton")
                    }
                    .padding(.top)
                    
                    if !resendAvailable {
                        Text("Wait \(remainingSeconds) seconds to resend the email")
                            .fontWeight(.thin)
                            .padding(.top, 5)
                    }
                    
                    if let resendMessage = viewModel.resendEmail {
                        Text(resendMessage)
                            .padding(.top)
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
                    
                    Button(action: {
                        Task {
                            await viewModel.verifyEmail()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation() {
                                viewModel.errorMessage = nil
                            }
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppColors.mainColor)
                            
                            Text("Proceed")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                                .padding(10)
                        }
                        .fixedSize()
                    }
                    .padding(.vertical)
                    .accessibilityIdentifier("proceedButton")
                }
                .padding(.horizontal)
                .frame(maxWidth: 800)
                Spacer()
            }
        }
        .onChange(of: viewModel.emailVerified, {
            if viewModel.emailVerified {
                navigationPath = NavigationPath()
            }
        })
        .onReceive(timer) { _ in
            if remainingSeconds > 1 {
                remainingSeconds -= 1
            } else {
                resendAvailable = true
            }
        }
        .background(colorScheme == .dark ? AppColors.backColorDark: Color(uiColor: .systemBackground))
    }
}
