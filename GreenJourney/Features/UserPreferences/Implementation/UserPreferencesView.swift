import Combine
import FirebaseAuth
import SwiftData
import SwiftUI

struct UserPreferencesView : View {
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
            VStack(spacing: 0) {
                HStack {
                    Text("Profile")
                        .font(.system(size: 32).bold())
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .padding(.bottom, 15)
                        .accessibilityIdentifier("userPreferencesTitle")
                    
                    Spacer()
                }
                
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
                
                Form {
                    Section {
                        HStack {
                            Text("First Name")
                            TextField("Not set", text: $userPreferencesViewModel.firstName)
                                .multilineTextAlignment(.trailing)
                                .accessibilityIdentifier("firstNameTextField")
                        }
                        
                        HStack {
                            Text("Last Name")
                            TextField("Not set", text: $userPreferencesViewModel.lastName)
                                .multilineTextAlignment(.trailing)
                                .accessibilityIdentifier("lastNameTextField")
                        }
                        
                        DatePicker("Birth date", selection: $userPreferencesViewModel.birthDate.toNonOptional(), in: Date.distantPast...Date(), displayedComponents: .date)
                            .accessibilityIdentifier("birthDatePicker")
                        
                        Picker("Gender", selection: $userPreferencesViewModel.gender) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue).tag(gender)
                            }
                        }
                        .pickerStyle(.automatic)
                        .accessibilityIdentifier("genderPicker")
                        
                        HStack {
                            Text("City")
                            TextField("Not set", text: $userPreferencesViewModel.city.toNonOptional())
                                .multilineTextAlignment(.trailing)
                                .accessibilityIdentifier("cityTextField")
                        }
                        
                        HStack {
                            Text("Street Name")
                            TextField("Not set", text: $userPreferencesViewModel.streetName.toNonOptional())
                                .multilineTextAlignment(.trailing)
                                .accessibilityIdentifier("streetNameTextField")
                        }
                        
                        HStack {
                            Text("House number")
                            TextField("Not set", text: userPreferencesViewModel.binding(for: $userPreferencesViewModel.houseNumber))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .accessibilityIdentifier("houseNumberTextField")
                        }
                        
                        HStack {
                            Text("Zip code")
                            TextField("Not set", text: userPreferencesViewModel.binding(for: $userPreferencesViewModel.zipCode))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .accessibilityIdentifier("zipCodeTextField")
                        }
                    }
                    .disabled(!editTapped)
                    
                    Section {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(email)
                                .accessibilityIdentifier("email")
                        }
                    }
                }
                .frame(height: 440)
                .contentMargins(.vertical, 0, for: .scrollContent)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                
                HStack {
                    Spacer()
                    
                    if showResendMessage {
                        Text("Email sent, check your inbox")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .accessibilityIdentifier("emailSentMessage")
                    }
                
                    Button ("Modify password") {
                        withAnimation() {
                            showResendMessage = true
                        }
                        Task {
                            await authenticationViewModel.resetPassword(email: email)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation() {
                                showResendMessage = false
                            }
                        }
                    }
                    .accessibilityIdentifier("modifyPasswordButton")
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 25))
                
                if let errorMessage = userPreferencesViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("errorMessage")
                }
                
                // logout button
                Button(action: {
                    authenticationViewModel.logout()
                     navigationPath = NavigationPath()
                    navigationPath.append(NavigationDestination.LoginView)
                }) {
                    Text("Logout")
                        .font(.title3)
                        .fontWeight(.regular)
                }
                .buttonStyle(.bordered)
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 10, trailing: 0))
                .accessibilityIdentifier("logoutButton")
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .onAppear(){
                userPreferencesViewModel.getUserData()
                
            }
            .background(colorScheme == .dark ? Color(red: 10/255, green: 10/255, blue: 10/255) : Color(red: 245/255, green: 245/255, blue: 245/255))
        } else {
            LoginView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
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

