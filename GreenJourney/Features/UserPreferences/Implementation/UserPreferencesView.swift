import Combine
import FirebaseAuth
import SwiftData
import SwiftUI

struct UserPreferencesView : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Environment(\.modelContext) private var modelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
    @Query var users: [User]
    let email: String = Auth.auth().currentUser?.email ?? ""
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var userPreferencesViewModel: UserPreferencesViewModel
    @StateObject private var authenticationViewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    @State var editTapped: Bool = false
    @State private var showResendMessage = false
    
    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        _userPreferencesViewModel = StateObject(wrappedValue: UserPreferencesViewModel(modelContext: modelContext, serverService: serverService))
        _authenticationViewModel = StateObject(wrappedValue: AuthenticationViewModel(modelContext: modelContext, serverService: serverService, firebaseAuthService: firebaseAuthService))
        _navigationPath = navigationPath
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    
    var body: some View {
        if let user = users.first {
            VStack {
                if horizontalSizeClass == .compact {
                    // iOS
                    ScrollView {
                        VStack {
                            // view title
                            UserPreferencesTitleView()
                            
                            // user data TextFields
                            UserPreferencesTextFieldsView(userPreferencesViewModel: userPreferencesViewModel, editTapped: editTapped, user: user)
                            
                            // password modification
                            PasswordModificationView(authenticationViewModel: authenticationViewModel, showResendMessage: showResendMessage)
                            
                            // error message
                            ErrorMessageView(userPreferencesViewModel: userPreferencesViewModel)
                            
                            // logout button
                            LogoutButtonView(authenticationViewModel: authenticationViewModel, navigationPath: $navigationPath)
                        }
                        .padding()
                    }
                    .scrollDismissesKeyboard(.immediately)
                    .frame(maxWidth: .infinity)
                } else {
                    // iPadOS
                    ScrollView {
                        HStack {
                            Spacer()
                            VStack {
                                // view title
                                UserPreferencesTitleView()
                                
                                // user data TextFields
                                UserPreferencesTextFieldsView(userPreferencesViewModel: userPreferencesViewModel, editTapped: editTapped, user: user)
                                
                                // password modification
                                PasswordModificationView(authenticationViewModel: authenticationViewModel, showResendMessage: showResendMessage)
                                
                                // error message
                                ErrorMessageView(userPreferencesViewModel: userPreferencesViewModel)
                                
                                // logout button
                                LogoutButtonView(authenticationViewModel: authenticationViewModel, navigationPath: $navigationPath)
                            }
                            .padding()
                            .frame(maxWidth: 800)
                            Spacer()
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                    .frame(maxWidth: .infinity)
                }
            }
            .refreshable {
                Task {
                    await authenticationViewModel.updateUserFromServer()
                    userPreferencesViewModel.getUserData()
                }
            }
            .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
            .onAppear(){
                userPreferencesViewModel.getUserData()
            }
        }
    }
}
extension Binding where Value == String? {
    func toNonOptional(defaultValue: String = "") -> Binding<String> {
        Binding<String>(
            get: { self.wrappedValue ?? defaultValue },
            set: { newValue in
                self.wrappedValue = newValue.isEmpty ? nil : newValue
            }
        )
    }
}
extension Binding where Value == Date? {
    func toNonOptional(defaultValue: Date = Date.now) -> Binding<Date> {
        Binding<Date>(
            get: { self.wrappedValue ?? defaultValue },
            set: { newValue in
                self.wrappedValue = newValue == Date.distantPast ? nil : newValue
            }
        )
    }
}

private struct UserPreferencesTitleView: View {
    var body: some View {
        HStack {
            Text("Profile")
                .font(.system(size: 32).bold())
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
                .accessibilityIdentifier("userPreferencesTitle")
            
            Spacer()
        }
    }
}

private struct UserPreferencesTextFieldsView: View {
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State var editTapped: Bool = false
    var user: User
    let email: String = Auth.auth().currentUser?.email ?? ""
    
    var body: some View {
        Text("Hi, \(user.firstName) \(user.lastName)")
            .font(.title)
            .accessibilityIdentifier("greetingMessage")
        
        Text("Help us know you better, complete your profile!")
            .font(.subheadline)
            .fontWeight(.light)
            .padding(.vertical)
            .frame(height: 80)
            .accessibilityIdentifier("completeProfileMessage")
        
        HStack {
            if editTapped {
                Button("Cancel") {
                    withAnimation(.default) {
                        editTapped = false
                    }
                    userPreferencesViewModel.cancelModifications()
                }
                .accessibilityIdentifier("cancelButton")
                
                Spacer()
                
                Button("Save") {
                    Task {
                        withAnimation(.default) {
                            editTapped = false
                        }
                        await userPreferencesViewModel.saveModifications()
                    }
                }
                .accessibilityIdentifier("saveButton")
            }
            else {
                Spacer()
                Button("Edit") {
                    withAnimation(.default) {
                        editTapped = true
                    }
                }
                .accessibilityIdentifier("editButton")
            }
        }
        .padding(EdgeInsets(top: 0, leading: 25, bottom: 10, trailing: 25))
        
        VStack(spacing: 30) {
            VStack {
                HStack {
                    Text("First Name")
                    TextField("Not set", text: $userPreferencesViewModel.firstName)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("firstNameTextField")
                }
                Divider()
                HStack {
                    Text("Last Name")
                    TextField("Not set", text: $userPreferencesViewModel.lastName)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("lastNameTextField")
                }
                Divider()
                DatePicker("Birth date", selection: $userPreferencesViewModel.birthDate.toNonOptional(), in: Date.distantPast...Date(), displayedComponents: .date)
                    .accessibilityIdentifier("birthDatePicker")
                Divider()
                HStack {
                    Text("Gender")
                    Spacer()
                    Picker("Gender", selection: $userPreferencesViewModel.gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.automatic)
                    .accessibilityIdentifier("genderPicker")
                }
                Divider()
                HStack {
                    Text("City")
                    TextField("Not set", text: $userPreferencesViewModel.city.toNonOptional())
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("cityTextField")
                }
                Divider()
                HStack {
                    Text("Street Name")
                    TextField("Not set", text: $userPreferencesViewModel.streetName.toNonOptional())
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("streetNameTextField")
                }
                Divider()
                HStack {
                    Text("House number")
                    TextField("Not set", text: userPreferencesViewModel.binding(for: $userPreferencesViewModel.houseNumber))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .accessibilityIdentifier("houseNumberTextField")
                }
                Divider()
                HStack {
                    Text("Zip code")
                    TextField("Not set", text: userPreferencesViewModel.binding(for: $userPreferencesViewModel.zipCode))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .accessibilityIdentifier("zipCodeTextField")
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? AppColors.blockColorDark : .white)
            }
            .disabled(!editTapped)
            
            VStack {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(email)
                        .accessibilityIdentifier("email")
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? AppColors.blockColorDark : .white)
            }
        }
        .frame(height: 440)
        .contentMargins(.vertical, 0, for: .scrollContent)
    }
}

private struct PasswordModificationView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @State var showResendMessage: Bool
    @State var remainingSeconds: Int = 60
    @State var resendAvailable: Bool = false
    @State var modifyTapped: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let email: String = Auth.auth().currentUser?.email ?? ""
    
    var body: some View {
        VStack {
            Button("Modify password") {
                modifyTapped = true
                
                Task {
                    await authenticationViewModel.resetPassword(email: email)
                }
            }
            .disabled(modifyTapped)
            .accessibilityIdentifier("modifyPasswordButton")
            
            
            if modifyTapped {
                HStack {
                    Text("Haven't received any email?")
                        .fontWeight(.thin)
                    Button(action: {
                        Task {
                            await authenticationViewModel.resetPassword(email: email)
                            resendAvailable = false
                            remainingSeconds = 60
                        }
                    }) {
                        Text("Resend email")
                            .font(.headline)
                            .underline()
                    }
                    .disabled(!resendAvailable)
                    .accessibilityIdentifier("resendEmailButton")
                }
                if !resendAvailable {
                    Text("Wait \(remainingSeconds) seconds to resend the email")
                        .fontWeight(.thin)
                        .padding(.top, 5)
                }
            }
        }
        .padding(.bottom, 20)
        .onReceive(timer) { _ in
            if modifyTapped {
                if remainingSeconds > 1 {
                    remainingSeconds -= 1
                } else {
                    resendAvailable = true
                }
            }
        }
    }
}

private struct ErrorMessageView: View {
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel
    
    var body: some View {
        if let errorMessage = userPreferencesViewModel.errorMessage {
            Text(errorMessage)
                .font(.caption)
                .foregroundStyle(.red)
                .accessibilityIdentifier("errorMessage")
        }
    }
}

private struct LogoutButtonView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        // logout button
        Button(action: {
            authenticationViewModel.logout()
            navigationPath = NavigationPath()
        }) {
            Text("Logout")
                .font(.title3)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("logoutButton")
    }
}
