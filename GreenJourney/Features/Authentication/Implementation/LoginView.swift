import SwiftUI
import SwiftData

struct LoginView: View {
    @StateObject var viewModel: AuthenticationViewModel
    private var modelContext: ModelContext
    @Binding var navigationPath: NavigationPath
   
    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        self.modelContext = modelContext
        _navigationPath = navigationPath
        _viewModel = StateObject(wrappedValue: AuthenticationViewModel(modelContext: modelContext, serverService: serverService, firebaseAuthService: firebaseAuthService))
      }
    
    var body: some View {
        VStack{
            Image("login_logo")
                .resizable()
                .padding()
                .aspectRatio(contentMode: .fit)
                .accessibilityIdentifier("loginLogoImage")
                .padding(.top, 50)
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
                        .accessibilityIdentifier("emailTextField")
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .accessibilityIdentifier("passwordSecureField")
                    
                    Button("Reset password") {
                        Task {
                            await viewModel.resetPassword(email: viewModel.email)
                        }
                    }
                    .accessibilityIdentifier("resetPasswordButton")
                    .padding(.vertical, 10)
                    
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
                    
                    VStack {
                        Button(action: {
                            Task {
                                viewModel.errorMessage = nil
                                viewModel.resendEmail = nil
                                await viewModel.login()
                            }
                        }) {
                            Text("Login")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(30)
                        }
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
                        Spacer()
                    }
                }
                .padding()
                VStack {
                    Text("Haven't signed up yet?")
                        .fontWeight(.light)
                    Button ("Sign up") {
                        viewModel.errorMessage = nil
                        navigationPath.append(NavigationDestination.SignupView(viewModel))
                    }
                    .accessibilityIdentifier("moveToSignUpButton")
                }
                .padding(.top, 15)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear() {
            viewModel.isEmailVerificationActiveLogin = false
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
        .navigationBarHidden(true)
    }
}
