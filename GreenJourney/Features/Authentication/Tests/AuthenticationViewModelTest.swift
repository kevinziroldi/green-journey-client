import SwiftData
import Testing

@testable import GreenJourney

struct AuthenticationViewModelTest {
    private var viewModel: AuthenticationViewModel
    private var mockModelContext: ModelContext
    private var mockModelContainer: ModelContainer
    private var mockServerService: MockServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    
    @MainActor
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = mockContainer
        self.mockModelContext = mockContainer.mainContext
        self.mockServerService = MockServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = AuthenticationViewModel(modelContext: mockContainer.mainContext, serverService: mockServerService, firebaseAuthService: mockFirebaseAuthService)
    }
    
    @Test
    func testLoginMissingData() async {
        // set email, not password
        viewModel.email = "test@test.com"
        
        await viewModel.login()
        // expect an error
        #expect(viewModel.isLogged == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testLoginWithCredentialsSuccessfulEmailNotVerified() async throws {
        // set email and password
        viewModel.email = "test@test.com"
        viewModel.password = "test"
        self.mockFirebaseAuthService.correctCredentials = true
        self.mockFirebaseAuthService.emailVerified = false
        
        await viewModel.login()
        
        // must verify email
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
        #expect(viewModel.isLogged == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isEmailVerificationActiveLogin)
    }
    
    @MainActor
    @Test
    func testLoginWithCredentialsSuccessfulEmailVerified() async throws {
        // set email and password
        viewModel.email = "test@test.com"
        viewModel.password = "test"
    
        self.mockFirebaseAuthService.correctCredentials = true
        self.mockFirebaseAuthService.emailVerified = true
        
        await viewModel.login()
        #expect(viewModel.isEmailVerificationActiveLogin == false)
        #expect(viewModel.isLogged == true)
        #expect(viewModel.errorMessage == nil)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
    }
    
    @Test
    func testLoginWithCredentialsFailed() async {
        // set email and password
        viewModel.email = "test@test.com"
        viewModel.password = "test"
        self.mockFirebaseAuthService.correctCredentials = false
        
        await viewModel.login()
        #expect(viewModel.isLogged == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    @MainActor
    @Test
    func testLogout() async throws {
        // set email and password
        viewModel.email = "test@test.com"
        viewModel.password = "test"
    
        self.mockFirebaseAuthService.correctCredentials = true
        self.mockFirebaseAuthService.emailVerified = true
        
        await viewModel.login()
        #expect(viewModel.isLogged == true)
        
        viewModel.logout()
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @Test
    func testResetPasswordEmptyEmail() async {
        await viewModel.resetPassword(email: "")
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testResetPasswordSuccessful() async {
        let email = "test@test.com"
        mockFirebaseAuthService.resetPasswordShouldSucceed = true
        
        await viewModel.resetPassword(email: email)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.resendEmail != nil)
    }
    
    @Test
    func testResetPasswordUnsuccessful() async {
        let email = "test@test.com"
        mockFirebaseAuthService.resetPasswordShouldSucceed = false
        
        await viewModel.resetPassword(email: email)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.resendEmail == nil)
    }
    
    @MainActor
    @Test
    func testSignupMissingData() async throws {
        viewModel.email = ""
        viewModel.password = ""
        viewModel.repeatPassword = ""
        viewModel.firstName = ""
        viewModel.lastName = ""
        
        await viewModel.signUp()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
}
