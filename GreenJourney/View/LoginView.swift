import SwiftUI

struct LoginView: View {
    @ObservedObject private var viewModel = LoginViewModel()
    @State private var isNavigationActive = false
    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .padding(.bottom, 32)
            
            TextField("Email", text: $viewModel.email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            HStack {
                if let resendMessage = viewModel.resendEmail {
                    Text(resendMessage)
                }
                Button("reset password") {
                    viewModel.resetPassword()
                }
            }
            // error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            
            Button(action: {
                viewModel.login()
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Spacer()
            Button ("Sign up") {
                isNavigationActive = true
            }
            .fullScreenCover(isPresented: $isNavigationActive) {
                SignUpView()
            }
        }
        .padding()
        .fullScreenCover(isPresented: $viewModel.isLogged) {
            MainView()
        }
        .navigationBarHidden(true)
    }
}
