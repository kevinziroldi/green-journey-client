import Combine
import FirebaseAuth
import SwiftData
import SwiftUI

struct UserPreferencesView : View {
    @Query var users: [User]
    let email: String = Auth.auth().currentUser?.email ?? ""
    @EnvironmentObject private var userPreferencesViewModel: UserPreferencesViewModel
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @Binding var navigationPath: NavigationPath
    @State var editTapped: Bool = false
    
    init(navigationPath: Binding<NavigationPath>) {
        _navigationPath = navigationPath
    }
    
    var body: some View {
        if let user = users.first {
            
            
            
            VStack(spacing: 0) {
                HStack {
                    Text("Profile")
                        .font(.title)
                        .padding(.leading)
                        .padding(.bottom, 15)
                    Spacer()
                }
                
                Text("Hi, \(user.firstName) \(user.lastName)")
                    .font(.title)
                //.padding(5)
                
                
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
                            withAnimation(.default) {
                                editTapped = false
                            }
                            userPreferencesViewModel.saveModifications()
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
                .padding(.horizontal, 15)
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
                        
                        DatePicker("Birth date", selection: $userPreferencesViewModel.birthDate.toNonOptional(), displayedComponents: .date)
                        
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
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Text("Street Name")
                            TextField("Not set", text: $userPreferencesViewModel.streetName.toNonOptional())
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
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
                .frame(height: 500)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                HStack {
                    Spacer()
                    Button ("Modify password") {
                        authenticationViewModel.resetPassword()
                    }
                    if let resendEmail = authenticationViewModel.resendEmail {
                        Text("email sent")
                    }
                }
                .padding(EdgeInsets(top: -10, leading: 0, bottom: 20, trailing: 30))
                
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
            .background(Color(red: 245/255, green: 245/255, blue: 245/255))
            
            
            
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

