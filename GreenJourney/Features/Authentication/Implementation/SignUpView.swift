import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("Signup")
                        .font(.system(size: 32).bold())
                        .padding()
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("signupTitle")
                    
                    VStack (spacing: 10) {
                        TextField("Email", text: $viewModel.email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .accessibilityIdentifier("emailTextField")
                        
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .accessibilityIdentifier("passwordSecureField")
                        
                        SecureField("Repeat Password", text: $viewModel.repeatPassword)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .accessibilityIdentifier("repeatPasswordSecureField")
                        
                        TextField("First name", text: $viewModel.firstName)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .accessibilityIdentifier("firstName")
                        
                        TextField("Last name", text: $viewModel.lastName)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .accessibilityIdentifier("lastName")
                        
                        // error message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .accessibilityIdentifier("errorMessageLabelSignup")
                        }
                    }
                    .padding(.top, 20)
                    VStack {
                        Button(action: {
                            Task {
                                await viewModel.signUp()
                            }
                        }) {
                            Text("Create account")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(30)
                        }
                        .accessibilityIdentifier("createAccountButton")
                        
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
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray, lineWidth: 1)
                                .fill(Color.white)
                                .shadow(radius: 1)
                            
                            Button(action: {
                                Task {
                                    await viewModel.signInWithGoogle()
                                }
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
                            .accessibilityIdentifier("googleSignInButton")
                        }
                        VStack {
                            Text("Already have an account?")
                                .fontWeight(.light)
                            Button ("Login") {
                                if !navigationPath.isEmpty {
                                    viewModel.errorMessage = nil
                                    viewModel.email = ""
                                    viewModel.password = ""
                                    viewModel.repeatPassword = ""
                                    navigationPath.removeLast()
                                }
                            }
                            .accessibilityIdentifier("moveToLoginButton")
                        }
                        .padding(.top, 100)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear() {
            viewModel.isEmailVerificationActiveSignup = false
        }
        .onChange(of: viewModel.isLogged, {
            if viewModel.isLogged {
                navigationPath = NavigationPath()
            }
        })
        .onChange(of: viewModel.isEmailVerificationActiveSignup, {
            if viewModel.isEmailVerificationActiveSignup {
                navigationPath.append(NavigationDestination.EmailVerificationView(viewModel))
            }
        })
        .navigationBarHidden(true)
    }
}

