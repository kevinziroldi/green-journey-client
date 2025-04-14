import Combine
import SwiftUI
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class UserPreferencesViewModelIntegrationTest {
    private var viewModel: UserPreferencesViewModel
    private var serverService: ServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    private var mockModelContainer: ModelContainer
    private var mockModelContext: ModelContext
    
    init() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        
        self.serverService = ServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = UserPreferencesViewModel(modelContext: container.mainContext, serverService: serverService)
        
        // clean database
        try await serverService.resetTestDatabase()
    }
    
    private func loginUser() async throws {
        let authenticationViewModel = AuthenticationViewModel(modelContext: self.mockModelContext, serverService: self.serverService, firebaseAuthService: self.mockFirebaseAuthService)
        
        // signup - creates the user
        authenticationViewModel.email = "test@test.com"
        authenticationViewModel.password = "test_password"
        authenticationViewModel.repeatPassword = "test_password"
        authenticationViewModel.firstName = "test_name"
        authenticationViewModel.lastName = "test_name"
        
        // firebase auth should succeed
        self.mockFirebaseAuthService.shouldSucceed = true
        
        await authenticationViewModel.signUp()
        #expect(authenticationViewModel.errorMessage == nil)
        #expect(authenticationViewModel.isLogged == false)
        
        // check SwiftData has no user
        var users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
        #expect(authenticationViewModel.isEmailVerificationActiveSignup == true)
        
        // verify email - already logs the user
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = true
        await authenticationViewModel.verifyEmail()
        #expect(authenticationViewModel.errorMessage == nil)
        
        #expect(authenticationViewModel.emailVerified == true)
        #expect(authenticationViewModel.isEmailVerificationActiveLogin == false)
        #expect(authenticationViewModel.isEmailVerificationActiveSignup == false)
        
        // check the user is in SwiftData
        users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
    }
    
    @Test
    func testGetUserData() async throws {
        // login
        try await loginUser()
        
        // call function
        viewModel.getUserData()
        
        #expect(viewModel.firstName == "test_name")
        #expect(viewModel.lastName == "test_name")
        #expect(viewModel.birthDate == nil)
        #expect(viewModel.gender == Gender.notSpecified)
        #expect(viewModel.city == nil)
        #expect(viewModel.streetName == nil)
        #expect(viewModel.houseNumber == nil)
        #expect(viewModel.zipCode == nil)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test
    func testUserDataModificationNoUser() async {
        // no user present
        
        await viewModel.saveModifications()
        
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testUserDataModification() async throws {
        // login
        try await loginUser()
        
        viewModel.getUserData()
        
        // add new data, correct type
        viewModel.houseNumber = 10
        // modify data, correct type
        viewModel.zipCode = 20
        
        await viewModel.saveModifications()
        
        #expect(viewModel.firstName == "test_name")
        #expect(viewModel.lastName == "test_name")
        #expect(viewModel.birthDate == nil)
        #expect(viewModel.gender == Gender.notSpecified)
        #expect(viewModel.city == nil)
        #expect(viewModel.streetName == nil)
        #expect(viewModel.houseNumber == 10)
        #expect(viewModel.zipCode == 20)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test
    func testCancelModifications() async throws {
        // login
        try await loginUser()
        
        viewModel.getUserData()
        
        // add new data, correct type
        viewModel.houseNumber = 10
        // modify data, correct type
        viewModel.zipCode = 20
        
        viewModel.cancelModifications()
        
        #expect(viewModel.firstName == "test_name")
        #expect(viewModel.lastName == "test_name")
        #expect(viewModel.birthDate == nil)
        #expect(viewModel.gender == Gender.notSpecified)
        #expect(viewModel.city == nil)
        #expect(viewModel.streetName == nil)
        #expect(viewModel.houseNumber == nil)
        #expect(viewModel.zipCode == nil)
        #expect(viewModel.errorMessage == nil)
    }
}
