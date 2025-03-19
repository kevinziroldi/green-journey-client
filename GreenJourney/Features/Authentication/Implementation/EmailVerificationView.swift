import SwiftUI

struct EmailVerificationView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var viewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    @State var remainingSeconds: Int = 60
    @State var resendAvailable: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
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
                Button (action: {
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
            
            Button (action: {
                Task {
                    await viewModel.verifyEmail()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation() {
                        viewModel.errorMessage = nil
                    }
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
        .onReceive(timer) { _ in
            if remainingSeconds > 1 {
                remainingSeconds -= 1
            } else {
                resendAvailable = true
            }
        }
    }
}



struct CountdownView: View {
    @State private var remainingSeconds = 10
    @State private var isTimeUp = false
    
    // Timer che emette ogni secondo
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("TIMER")
            Spacer()
            if isTimeUp {
                Text("Tempo scaduto!")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                Spacer()
                Button("restart timer") {
                    isTimeUp = false
                    remainingSeconds = 10
                }
            } else {
                Text("Tempo rimanente: \(remainingSeconds)")
                    .font(.largeTitle)
            }
            Spacer()
            
            
        }
        .onReceive(timer) { _ in
            if remainingSeconds > 1 {
                remainingSeconds -= 1
            } else {
                isTimeUp = true
                // Qui eventualmente puoi fermare il timer se non ti serve più
            }
        }
        .padding()
    }
}
