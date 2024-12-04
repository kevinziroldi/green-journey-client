import SwiftUI
import SwiftData

struct LoginView: View {
    @EnvironmentObject private var viewModel: AuthenticationViewModel
    @State private var isNavigationActive = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack{
            Text("Login")
                .font(.largeTitle)
                .padding(.bottom, 32)
            Image("loginLogo")
                .resizable()
                .padding()
                .aspectRatio(contentMode: .fit)
            ScrollView {
                VStack {
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
                                .cornerRadius(30)
                        }
                        .fullScreenCover(isPresented: $viewModel.isEmailVerificationActive) {
                            EmailVerificationView()
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
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray, lineWidth: 1)
                                .fill(Color.white)
                                .shadow(radius: 1)
                            
                            
                            Button(action: {
                                Task{await viewModel.signInWithGoogle()}
                            }) {
                                HStack(spacing: 10) {
                                    Image("googleLogo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60)
                                        .safeAreaPadding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                                    Spacer()
                                    Text("Sign in with Google")
                                        .foregroundStyle(.black)
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                }
                                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                                
                            }
                        }
                        
                        
                        Spacer()
                        
                    }
                }
                .padding()
                .fullScreenCover(isPresented: $viewModel.isLogged) {
                    MainView(modelContext: modelContext)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            
            Button ("Sign up") {
                isNavigationActive = true
                viewModel.resetParameters()
            }
            .fullScreenCover(isPresented: $isNavigationActive, onDismiss: ({ isNavigationActive = false
                viewModel.resetParameters()})) {
                SignUpView()
            }
        }
        .navigationBarHidden(true)
    }
}
