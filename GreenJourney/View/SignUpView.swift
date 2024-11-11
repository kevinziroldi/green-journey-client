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
            
            Image("prova2")
                .resizable()
                .padding()
                .aspectRatio(contentMode: .fit)
            
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
            
            VStack (spacing: 20) {
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
                
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                    
                    Text("OR")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                
                Button (action: {Task{await viewModel.signInWithGoogle()}}){
                    Image("googleLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .padding(.trailing, 8)
                    Text("Sign in with Google")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Spacer()
                Button ("Login") {
                    isNavigationLoginActive = true
                }
                .fullScreenCover(isPresented: $isNavigationLoginActive) {
                    LoginView(modelContext: modelContext)
                }
            }
        }
        .padding()
        .navigationBarHidden(true)
    }
}
