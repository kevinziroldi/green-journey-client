import SwiftUI
import SwiftData

struct LoginView: View {
    @StateObject private var viewModel: AuthenticationViewModel
    @State private var isNavigationActive = false
    @Environment(\.modelContext) private var modelContext
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: AuthenticationViewModel(modelContext: modelContext))
    }

    var body: some View {
        ScrollView {
            VStack {
                Text("Login")
                    .font(.largeTitle)
                    .padding(.bottom, 32)
                Image("prova2")
                    .resizable()
                    .padding()
                    .aspectRatio(contentMode: .fit)
                Spacer()
                
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                HStack {
                    if let resendMessage = viewModel.resendEmail {
                        Text(resendMessage)
                    }
                    Button("Reset password") {
                        viewModel.resetPassword()
                    }
                }
                // error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                VStack(spacing: 20) {
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
                    .fullScreenCover(isPresented: $viewModel.isEmailVerificationActive) {
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
                    Button ("Sign up") {
                        isNavigationActive = true
                    }
                    .fullScreenCover(isPresented: $isNavigationActive) {
                        SignUpView(viewModel: viewModel)
                    }
                }
            }
            .padding()
            .fullScreenCover(isPresented: $viewModel.isLogged) {
                MainView(modelContext: modelContext)
            }
            .navigationBarHidden(true)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
