import SwiftUI
import SwiftData

struct LoginView: View {
    @EnvironmentObject private var viewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack{
            Image("login_logo_map")
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
            }
            .scrollDismissesKeyboard(.interactively)
            
            Button ("Sign up") {
                navigationPath.append(NavigationDestination.SignupView)
            }
        }
        .onAppear() {
            viewModel.resetParameters()
            viewModel.isEmailVerificationActiveLogin = false
        }
        .onChange(of: viewModel.isLogged, {
            if viewModel.isLogged {
                navigationPath = NavigationPath()
            }
        })
        .onChange(of: viewModel.isEmailVerificationActiveLogin, {
            if viewModel.isEmailVerificationActiveLogin {
                navigationPath.append(NavigationDestination.EmailVerificationView)
            }
        })
        .navigationBarHidden(true)
    }
}
