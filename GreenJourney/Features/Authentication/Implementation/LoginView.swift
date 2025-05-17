import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @StateObject private var viewModel: AuthenticationViewModel
    private var modelContext: ModelContext
    @Binding private var navigationPath: NavigationPath
    
    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        self.modelContext = modelContext
        _navigationPath = navigationPath
        _viewModel = StateObject(wrappedValue: AuthenticationViewModel(modelContext: modelContext, serverService: serverService, firebaseAuthService: firebaseAuthService))
    }
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            ScrollView {
                VStack {
                    // logo
                    LogoView()
                    
                    Spacer()
                    
                    // email+password TextFields
                    LoginTextFieldsView(viewModel: viewModel)
                    
                    // reset password button
                    ResetPasswordButtonView(viewModel: viewModel)
                    
                    // error message and resend email message
                    MessagesView(viewModel: viewModel)
                    
                    // login buttons
                    LoginButtonsView(viewModel: viewModel)
                    
                    // move to signup
                    MoveToSignupView(viewModel: viewModel, navigationPath: $navigationPath)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear() {
                viewModel.isEmailVerificationActiveLogin = false
            }
            .onChange(of: viewModel.isEmailVerificationActiveLogin, {
                if viewModel.isEmailVerificationActiveLogin {
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
                    // logo
                    LogoView()
                        .frame(maxWidth: 500)
                    
                    Spacer()
                    
                    // email+password TextFields
                    LoginTextFieldsView(viewModel: viewModel)
                        .padding(.horizontal, 50)
                    
                    // reset password button
                    ResetPasswordButtonView(viewModel: viewModel)
                    
                    // error message and resend email message
                    MessagesView(viewModel: viewModel)
                    
                    // login buttons
                    LoginButtonsView(viewModel: viewModel)
                        .frame(maxWidth: 600)
                    
                    // move to signup
                    MoveToSignupView(viewModel: viewModel, navigationPath: $navigationPath)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear() {
                viewModel.isEmailVerificationActiveLogin = false
                viewModel.isPresenting = false
            }
            .onChange(of: viewModel.isLogged, {
                if viewModel.isLogged {
                    navigationPath = NavigationPath()
                }
            })
            .onChange(of: viewModel.isEmailVerificationActiveLogin, {
                if viewModel.isEmailVerificationActiveLogin {
                    navigationPath.append(NavigationDestination.EmailVerificationView(viewModel))
                }
            })
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden(true)
            .background(colorScheme == .dark ? AppColors.backColorDark: Color(uiColor: .systemBackground))
        }
    }
}

private struct LogoView: View {
    var body: some View {
        Image("login_logo")
            .resizable()
            .padding()
            .aspectRatio(contentMode: .fit)
            .accessibilityIdentifier("loginLogoImage")
            .padding(.top, 50)
    }
}

private struct LoginTextFieldsView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .textInputAutocapitalization(.never)
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
        }
    }
}

private struct ResetPasswordButtonView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        Button("Reset password") {
            if !viewModel.isPresenting {
                viewModel.isPresenting = true
                Task {
                    await viewModel.resetPassword(email: viewModel.email)
                    try await Task.sleep(for: .seconds(0.5))
                    viewModel.isPresenting = false
                }
            }
        }
        .accessibilityIdentifier("resetPasswordButton")
        .padding(.vertical, 10)
    }
}

private struct MessagesView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        // error message
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .foregroundColor(.red)
                .accessibilityIdentifier("errorMessageLabelLogin")
        }
        
        if let resendMessage = viewModel.resendEmail {
            Text(resendMessage)
                .accessibilityIdentifier("resendEmailLabel")
        }
    }
}

private struct LoginButtonsView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                if !viewModel.isPresenting {
                    viewModel.isPresenting = true
                    Task {
                        viewModel.errorMessage = nil
                        viewModel.resendEmail = nil
                        await viewModel.login()
                        try await Task.sleep(for: .seconds(0.5))
                        viewModel.isPresenting = false
                    }
                }
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.mainColor)
                    .cornerRadius(30)
            }
            .disabled(viewModel.isLoading)
            .accessibilityIdentifier("loginButton")
            
            
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
                            try await Task.sleep(for: .seconds(0.5))
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
            Spacer()
        }
    }
}

private struct MoveToSignupView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            Text("Haven't signed up yet?")
                .fontWeight(.light)
            Button("Sign up") {
                if !viewModel.isPresenting {
                    viewModel.isPresenting = true
                    viewModel.errorMessage = nil
                    viewModel.email = ""
                    viewModel.password = ""
                    navigationPath.append(NavigationDestination.SignupView(viewModel))
                }
            }
            .accessibilityIdentifier("moveToSignUpButton")
        }
        .padding(.top, 15)
    }
}
