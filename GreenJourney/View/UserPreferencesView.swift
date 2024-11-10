import Combine
import FirebaseAuth
import SwiftData
import SwiftUI

struct UserPreferencesView : View {
    @Environment(\.modelContext) private var modelContext
    @Query var users: [User]
    let email: String = Auth.auth().currentUser?.email ?? ""
    @StateObject private var viewModel: UserPreferencesViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: UserPreferencesViewModel(modelContext: modelContext))
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
                    TextField("First Name", text: $viewModel.firstNameField)
                        .onChange(of: viewModel.firstNameField) {
                            viewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Last Name", text: $viewModel.lastNameField)
                        .onChange(of: viewModel.lastNameField) {
                            viewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    DatePicker("Birth date", selection: $viewModel.birthDateField.toNonOptional(), displayedComponents: .date)
                        .onChange(of: viewModel.birthDateField) {
                            viewModel.hasModified = true
                        }
                    
                    Picker("Gender", selection: $viewModel.genderField) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: viewModel.genderField) {
                        viewModel.hasModified = true
                    }
                    
                    TextField("City", text: $viewModel.cityField.toNonOptional())
                        .onChange(of: viewModel.cityField) {
                            viewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Street name", text: $viewModel.streetNameField.toNonOptional())
                        .onChange(of: viewModel.streetNameField) {
                            viewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("House number", value: $viewModel.houseNumberField.toNonOptional(), formatter: NumberFormatter())
                        .onChange(of: viewModel.houseNumberField) {
                            viewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Zip code", value: $viewModel.zipCodeField.toNonOptional(), formatter: NumberFormatter())
                        .onChange(of: viewModel.zipCodeField) {
                            viewModel.hasModified = true
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                .cornerRadius(15)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                if viewModel.hasModified {
                    Button(action: viewModel.saveModifications) {
                        Text("Save Modifications")
                    }
                }

                // logout button
                Button("Logout") {
                    viewModel.logout(user: user)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .onAppear() {
                viewModel.getUserData()
                viewModel.hasModified = false
            }
        } else {
            LoginView(modelContext: modelContext)
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
    func toNonOptional(defaultValue: Date = Date.distantPast) -> Binding<Date> {
        Binding<Date>(
            get: { self.wrappedValue ?? defaultValue },
            set: { newValue in
                self.wrappedValue = newValue == Date.distantPast ? nil : newValue
            }
        )
    }
}
