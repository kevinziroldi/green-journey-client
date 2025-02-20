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
                    Spacer()
                }
                
                Text("Hi, \(user.firstName) \(user.lastName)")
                    .font(.title)
                
                
                Text("Do you want to get better predictions about your future travels? Complete your profile!")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .padding(.vertical)
                    .frame(height: 80)
                HStack {
                    if editTapped {
                        Button("Cancel") {
                            withAnimation(.default) {
                                editTapped = false
                            }
                            userPreferencesViewModel.cancelModifications()
                        }
                        Spacer()
                        Button("Save") {
                            Task {
                                withAnimation(.default) {
                                    editTapped = false
                                }
                                await userPreferencesViewModel.saveModifications()
                            }
                        }
                    }
                    else {
                        Spacer()
                        Button("Edit") {
                            withAnimation(.default) {
                                editTapped = true
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 25, bottom: 10, trailing: 25))
                
                Form {
                    Section {
                        HStack {
                            Text("First Name")
                            TextField("Not set", text: $userPreferencesViewModel.firstName)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Last Name")
                            TextField("Not set", text: $userPreferencesViewModel.lastName)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        DatePicker("Birth date", selection: $userPreferencesViewModel.birthDate.toNonOptional(), in: Date.distantPast...Date(), displayedComponents: .date)
                        
                        Picker("Gender", selection: $userPreferencesViewModel.gender) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue).tag(gender)
                            }
                        }
                        .pickerStyle(.automatic)
                        
                        HStack {
                            Text("City")
                            TextField("Not set", text: $userPreferencesViewModel.city.toNonOptional())
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Street Name")
                            TextField("Not set", text: $userPreferencesViewModel.streetName.toNonOptional())
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("House number")
                            TextField("Not set", text: userPreferencesViewModel.binding(for: $userPreferencesViewModel.houseNumber))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Text("Zip code")
                            TextField("Not set", text: userPreferencesViewModel.binding(for: $userPreferencesViewModel.zipCode))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                    }
                    .disabled(!editTapped)
                    Section {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(email)
                        }
                    }
                }
                .frame(height: 440)
                .contentMargins(.vertical, 0, for: .scrollContent)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                HStack {
                    Spacer()
                    if let resendEmail = authenticationViewModel.resendEmail {
                        if showResendMessage {
                            Text(resendEmail)
                                .font(.subheadline)
                                .fontWeight(.light)
                        }
                        
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
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 25))
                
                if let errorMessage = userPreferencesViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
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

