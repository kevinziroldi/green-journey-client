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
                    TextField("First Name", text: $userPreferencesViewModel.firstName)
                        .onChange(of: userPreferencesViewModel.firstName) {
                            userPreferencesViewModel.checkForModifications()
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Last Name", text: $userPreferencesViewModel.lastName)
                        .onChange(of: userPreferencesViewModel.lastName) {
                            userPreferencesViewModel.checkForModifications()

                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    DatePicker("Birth date", selection: $userPreferencesViewModel.birthDate.toNonOptional(), displayedComponents: .date)
                        .onChange(of: userPreferencesViewModel.birthDate) {
                            userPreferencesViewModel.checkForModifications()

                        }
                    Picker("Gender", selection: $userPreferencesViewModel.gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: userPreferencesViewModel.gender) {
                        userPreferencesViewModel.checkForModifications()

                    }
                    TextField("City", text: $userPreferencesViewModel.city.toNonOptional())
                        .onChange(of: userPreferencesViewModel.city) {
                            userPreferencesViewModel.checkForModifications()

                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Street name", text: $userPreferencesViewModel.streetName.toNonOptional())
                        .onChange(of: userPreferencesViewModel.streetName) {
                            userPreferencesViewModel.checkForModifications()

                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("House number", value: $userPreferencesViewModel.houseNumber.toNonOptional(), formatter: NumberFormatter())
                        .onChange(of: userPreferencesViewModel.houseNumber) {
                            userPreferencesViewModel.checkForModifications()

                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Zip code", value: $userPreferencesViewModel.zipCode.toNonOptional(), formatter: NumberFormatter())
                        .onChange(of: userPreferencesViewModel.zipCode) {
                            userPreferencesViewModel.checkForModifications()

                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                .cornerRadius(15)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                if userPreferencesViewModel.hasModified {
                    Button(action: userPreferencesViewModel.saveModifications) {
                        Text("Save modifications")
                    }
                    .buttonStyle(.bordered)
                   
                    Button(action: userPreferencesViewModel.cancelModifications) {
                        Text("Cancel modifications")
                    }
                    .buttonStyle(.bordered)
                    
                }

                // logout button
                Button("Logout") {
                    authenticationViewModel.logout()
                    navigationPath = NavigationPath()
                    navigationPath.append(NavigationDestination.LoginView)
                }
                .buttonStyle(.bordered)

            }
            .frame(maxWidth: .infinity)
            .padding()
            .onAppear(){
                userPreferencesViewModel.getUserData()
                
            }
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
