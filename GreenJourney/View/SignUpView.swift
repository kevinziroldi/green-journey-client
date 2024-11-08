import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var isNavigationLoginActive = false
    @State private var isEmailVerificationActive = false
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Text("Sign Up")
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
            SecureField("Repeat Password", text: $viewModel.repeatPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            TextField("First name", text: $viewModel.firstName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            TextField("Last name", text: $viewModel.lastName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            // error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            Button(action: {
                viewModel.signUp()
                isEmailVerificationActive = true
            }) {
                Text("Create account")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .fullScreenCover(isPresented: $isEmailVerificationActive) {
                EmailVerificationView(viewModel: viewModel)
            }
            
            Spacer()
            Button ("Login") {
                isNavigationLoginActive = true
            }
            .fullScreenCover(isPresented: $isNavigationLoginActive) {
                LoginView(modelContext: modelContext)
            }
        }
        .padding()
        .navigationBarHidden(true)
    }
}
