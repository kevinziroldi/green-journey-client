import SwiftUI

struct SignUpView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var viewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            ScrollView {
                VStack {
                    // signup title
                    SignupTitleView()
                    
                    // signup TextFields
                    SignupDataFieldsView(viewModel: viewModel)
                        .padding(.top, 20)
                    
                    // signup button
                    SignupButtonsView(viewModel: viewModel, navigationPath: $navigationPath)
                        .padding(.top, 20)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear() {
                Task {
                    try await Task.sleep(for: .seconds(1))
                    viewModel.isPresenting = false
                }
                viewModel.isEmailVerificationActiveSignup = false
                viewModel.isLoading = false
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
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden(true)
            .background(colorScheme == .dark ? AppColors.backColorDark: Color(uiColor: .systemBackground))
        } else {
            // iPadOS
            
            ScrollView {
                VStack {
                    // signup title
                    SignupTitleView()
                    
                    // signup TextFields
                    SignupDataFieldsView(viewModel: viewModel)
                        .padding(.top, 20)
                        .padding(.horizontal, 50)
                    
                    // signup button
                    SignupButtonsView(viewModel: viewModel, navigationPath: $navigationPath)
                        .frame(maxWidth: 600)
                        .padding(.top, 20)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear() {
                viewModel.isEmailVerificationActiveSignup = false
                Task {
                    try await Task.sleep(for: .seconds(1))
                    viewModel.isPresenting = false
                }
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
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden(true)
            .background(colorScheme == .dark ? AppColors.backColorDark: Color(uiColor: .systemBackground))
        }
    }
}

private struct SignupTitleView: View {
    var body: some View {
        Text("Signup")
            .font(.system(size: 32).bold())
            .padding()
            .fontWeight(.semibold)
            .accessibilityIdentifier("signupTitle")
    }
}

private struct SignupDataFieldsView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
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
                .textContentType(.oneTimeCode)
                .accessibilityIdentifier("passwordSecureField")
            
            SecureField("Repeat Password", text: $viewModel.repeatPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .textContentType(.oneTimeCode)
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
    }
}

private struct SignupButtonsView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            Button(action: {
                if !viewModel.isPresenting {
                    viewModel.isPresenting = true
                    Task {
                        await viewModel.signUp()
                        viewModel.isPresenting = false
                    }
                }
            }) {
                Text("Create account")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.mainColor)
                    .cornerRadius(30)
            }
            .disabled(viewModel.isLoading)
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
                    if !viewModel.isPresenting {
                        viewModel.isPresenting = true
                        Task {
                            await viewModel.signInWithGoogle()
                            viewModel.isPresenting = false
                        }
                    }
                }) {
                    ZStack {
                        HStack {
                            Image("googleLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .padding(.leading, 20)
                            Spacer()
                        }
                        Text("Sign in with Google")
                            .foregroundStyle(.black)
                    }
                    .padding(.vertical, 5)
                }
                .accessibilityIdentifier("googleSignInButton")
            }
            VStack {
                Text("Already have an account?")
                    .fontWeight(.light)
                Button("Login") {
                    if !viewModel.isPresenting {
                        viewModel.isPresenting = true
                        
                        if !navigationPath.isEmpty {
                            viewModel.errorMessage = nil
                            viewModel.email = ""
                            viewModel.password = ""
                            viewModel.repeatPassword = ""
                            viewModel.firstName = ""
                            viewModel.lastName = ""
                            navigationPath.removeLast()
                        }
                        viewModel.isPresenting = false
                    }
                }
                .accessibilityIdentifier("moveToLoginButton")
            }
            .padding(.top, 45)
        }
    }
}
