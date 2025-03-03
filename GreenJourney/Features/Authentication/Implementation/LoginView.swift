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
            ScrollView {
                VStack {
                    Image("login_logo")
                        .resizable()
                        .padding()
                        .aspectRatio(contentMode: .fit)
                        .accessibilityIdentifier("loginLogoImage")
                        .padding(.top, 50)
                        .frame(maxWidth: 500)
                    
                    Spacer()
                    
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
                            .accessibilityIdentifier("passwordSecureField")
                    }
                    .padding(.horizontal, 30)
                    
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
                                ZStack {
                                    HStack{
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
                    .frame(maxWidth: 600)
                }
                .padding()
                VStack {
                    Text("Haven't signed up yet?")
                        .fontWeight(.light)
                    Button ("Sign up") {
                        viewModel.errorMessage = nil
                        viewModel.email = ""
                        viewModel.password = ""
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
