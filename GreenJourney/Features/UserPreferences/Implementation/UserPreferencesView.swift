import Combine
import FirebaseAuth
import SwiftData
import SwiftUI

struct UserPreferencesView : View {
    @Environment(\.modelContext) private var modelContext
    @Query var users: [User]
    let email: String = Auth.auth().currentUser?.email ?? ""
    @EnvironmentObject private var userPreferencesViewModel: UserPreferencesViewModel
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    
    init(navigationPath: Binding<NavigationPath>) {
        _navigationPath = navigationPath
    }
    
    var body: some View {
        if let user = users.first {
            VStack() {
                HStack {
                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }.padding()
                
                Text("Hi, \(user.firstName) \(user.lastName)")
                    .font(.title2)
                    .padding()
                
                // email and password
                VStack(spacing: 8) {
                    Text("Email: \(email)")
                        .font(.body)
                    Button("Modify Password") {
                        // TODO
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                Text("Do you want to get better predictions about your future travels? Complete your profile!")
                
                VStack() {
                    TextField("First Name", text: $userPreferencesViewModel.firstNameField)
                        .onChange(of: userPreferencesViewModel.firstNameField) {
                            userPreferencesViewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Last Name", text: $userPreferencesViewModel.lastNameField)
                        .onChange(of: userPreferencesViewModel.lastNameField) {
                            userPreferencesViewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    DatePicker("Birth date", selection: $userPreferencesViewModel.birthDateField.toNonOptional(), displayedComponents: .date)
                        .onChange(of: userPreferencesViewModel.birthDateField) {
                            userPreferencesViewModel.hasModified = true
                        }
                    Picker("Gender", selection: $userPreferencesViewModel.genderField) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: userPreferencesViewModel.genderField) {
                        userPreferencesViewModel.hasModified = true
                    }
                    TextField("City", text: $userPreferencesViewModel.cityField.toNonOptional())
                        .onChange(of: userPreferencesViewModel.cityField) {
                            userPreferencesViewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Street name", text: $userPreferencesViewModel.streetNameField.toNonOptional())
                        .onChange(of: userPreferencesViewModel.streetNameField) {
                            userPreferencesViewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("House number", value: $userPreferencesViewModel.houseNumberField.toNonOptional(), formatter: NumberFormatter())
                        .onChange(of: userPreferencesViewModel.houseNumberField) {
                            userPreferencesViewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Zip code", value: $userPreferencesViewModel.zipCodeField.toNonOptional(), formatter: NumberFormatter())
                        .onChange(of: userPreferencesViewModel.zipCodeField) {
                            userPreferencesViewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                .cornerRadius(15)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                if !userPreferencesViewModel.initializationPhase && userPreferencesViewModel.hasModified {
                    Button(action: userPreferencesViewModel.saveModifications) {
                        Text("Save modifications")
                    }
                   
                    Button(action: userPreferencesViewModel.cancelModifications) {
                        Text("Cancel modifications")
                    }
                    
                }

                // logout button
                Button("Logout") {
                    authenticationViewModel.logout(user: user)
                    navigationPath = NavigationPath()
                    navigationPath.append(NavigationDestination.LoginView)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        } else {
            LoginView(navigationPath: $navigationPath)
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

extension Binding where Value == Int? {
    func toNonOptional(defaultValue: Int = 0) -> Binding<Int> {
        Binding<Int>(
            get: { self.wrappedValue ?? defaultValue },
            set: { newValue in
                self.wrappedValue = newValue == 0 ? nil : newValue
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
