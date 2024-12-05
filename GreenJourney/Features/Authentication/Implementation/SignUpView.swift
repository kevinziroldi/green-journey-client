import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("Sign Up")
                        .font(.largeTitle)
                        .padding(.bottom, 32)
                    
                    Image("loginLogo")
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
                            
                            if viewModel.isEmailVerificationActive {
                                navigationPath.append(NavigationDestination.EmailVerificationView)
                            }
                        }) {
                            Text("Create account")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
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
                        
                        Button (action: {
                            Task{await viewModel.signInWithGoogle()}
                        }){
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
                            if !navigationPath.isEmpty {
                                navigationPath.removeLast()
                            }
                        }
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear() {
            viewModel.resetParameters()
        }
        .onChange(of: viewModel.isLogged, {
            if viewModel.isLogged {
                navigationPath = NavigationPath()
            }
        })
        .navigationBarHidden(true)
    }
}
