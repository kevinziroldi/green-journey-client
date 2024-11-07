import SwiftUI
import SwiftData

struct LoginView: View {
    @State private var isNavigationActive = false
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: AuthenticationViewModel
    
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
            
            Button (action: {Task{await viewModel.signInWithGoogle()}}){
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
        .padding()
        .fullScreenCover(isPresented: $viewModel.isLogged) {
            MainView()
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.checkUserLogged()
        }
    }
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: AuthenticationViewModel(modelContext: modelContext))
    }
}
