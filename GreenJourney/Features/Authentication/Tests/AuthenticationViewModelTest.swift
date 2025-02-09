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
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = false
        self.mockServerService.shouldSucceed = true
        
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
    
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = true
        self.mockServerService.shouldSucceed = true
        
        await viewModel.login()
        #expect(viewModel.isEmailVerificationActiveLogin == false)
        #expect(viewModel.isLogged == true)
        #expect(viewModel.errorMessage == nil)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
    }
    
    @Test
    func testLoginWrongCredentials() async {
        // set email and password
        viewModel.email = "test@test.com"
        viewModel.password = "test"
        self.mockFirebaseAuthService.shouldSucceed = false
        self.mockServerService.shouldSucceed = true
        
        await viewModel.login()
        #expect(viewModel.isLogged == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testLoginServerFailed() async {
        // set email and password
        viewModel.email = "test@test.com"
        viewModel.password = "test"
        self.mockFirebaseAuthService.shouldSucceed = false
        self.mockServerService.shouldSucceed = false
        
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
    
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = true
        // no interaction with server
        
        await viewModel.login()
        #expect(viewModel.isLogged == true)
        
        viewModel.logout()
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @Test
    func testResetPasswordEmptyEmail() async {
        // no interaction with server
        await viewModel.resetPassword(email: "")
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testResetPasswordSuccessful() async {
        let email = "test@test.com"
        mockFirebaseAuthService.shouldSucceed = true
        // no interaction with server
        
        await viewModel.resetPassword(email: email)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.resendEmail != nil)
    }
    
    @Test
    func testResetPasswordUnsuccessful() async {
        let email = "test@test.com"
        mockFirebaseAuthService.shouldSucceed = false
        // no interaction with server
        
        await viewModel.resetPassword(email: email)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.resendEmail == nil)
    }
    
    @MainActor
    @Test
    func testSignupMissingLoginData() async throws {
        viewModel.email = ""
        viewModel.password = ""
        viewModel.repeatPassword = ""
        viewModel.firstName = "test_name"
        viewModel.lastName = "test_name"
        
        await viewModel.signUp()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @MainActor
    @Test
    func testSignupMissingNameData() async throws {
        viewModel.email = "test@test.com"
        viewModel.password = "test_password"
        viewModel.repeatPassword = "test_password"
        viewModel.firstName = ""
        viewModel.lastName = ""
        
        await viewModel.signUp()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @MainActor
    @Test
    func testSignupRepeatPasswordWrong() async throws {
        // fill all fields
        viewModel.email = "test@test.com"
        viewModel.password = "test_password"
        // repeat password different from password
        viewModel.repeatPassword = "test_password_diff"
        viewModel.firstName = "test_name"
        viewModel.lastName = "test_name"
        
        await viewModel.signUp()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @MainActor
    @Test
    func testSignupFirebaseFails() async throws {
        // fill all fields
        viewModel.email = "test@test.com"
        viewModel.password = "test_password"
        viewModel.repeatPassword = "test_password"
        viewModel.firstName = "test_name"
        viewModel.lastName = "test_name"

        // firebase auth should fail
        self.mockFirebaseAuthService.shouldSucceed = false
        self.mockServerService.shouldSucceed = true
        
        await viewModel.signUp()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @MainActor
    @Test
    func testSignupServerFails() async throws {
        // fill all fields
        viewModel.email = "test@test.com"
        viewModel.password = "test_password"
        viewModel.repeatPassword = "test_password"
        viewModel.firstName = "test_name"
        viewModel.lastName = "test_name"

        // firebase auth should fail
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockServerService.shouldSucceed = false
        
        await viewModel.signUp()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @MainActor
    @Test
    func testSignupSuccessful() async throws {
        // fill all fields
        viewModel.email = "test@test.com"
        viewModel.password = "test_password"
        viewModel.repeatPassword = "test_password"
        viewModel.firstName = "test_name"
        viewModel.lastName = "test_name"

        // firebase auth should fail
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockServerService.shouldSucceed = true
        
        await viewModel.signUp()
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
        #expect(viewModel.isEmailVerificationActiveSignup == true)
    }
    
    @Test
    func testSendEmailVerificationFirebaseFailed() async {
        self.mockFirebaseAuthService.shouldSucceed = false
        self.mockServerService.shouldSucceed = true
        await viewModel.sendEmailVerification()
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testSendEmailVerificationSuccessful() async {
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockServerService.shouldSucceed = true
        await viewModel.sendEmailVerification()
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test
    func testVerifyEmailFirebaseFailed() async {
        self.mockFirebaseAuthService.shouldSucceed = false
        self.mockServerService.shouldSucceed = true
        await viewModel.verifyEmail()
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testVerifyEmailServerFailed() async {
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = true
        self.mockServerService.shouldSucceed = false
        await viewModel.verifyEmail()
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testVerifyEmailNotVerified() async {
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = false
        self.mockFirebaseAuthService.shouldSucceed = true
        await viewModel.verifyEmail()
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testVerifyEmailVerified() async {
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = true
        self.mockFirebaseAuthService.shouldSucceed = true
        await viewModel.verifyEmail()
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test
    func testSignInGoogleFirebaseFailed() async throws {
        self.mockFirebaseAuthService.shouldSucceed = false
        self.mockServerService.shouldSucceed = true
        
        await viewModel.signInWithGoogle()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @Test
    func testSignInGoogleServerFailedLogin() async throws {
        self.mockFirebaseAuthService.shouldSucceed = true
        // login - not new user
        self.mockFirebaseAuthService.isNewUser = false
        self.mockServerService.shouldSucceed = false
        
        await viewModel.signInWithGoogle()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @Test
    func testSignInGoogleServerFailedSignup() async throws {
        self.mockFirebaseAuthService.shouldSucceed = true
        // signup - new user
        self.mockFirebaseAuthService.isNewUser = true
        self.mockServerService.shouldSucceed = false
        
        await viewModel.signInWithGoogle()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @Test
    func testSignInGoogleSuccessfulLogin() async throws {
        self.mockFirebaseAuthService.shouldSucceed = true
        // login - not new user
        self.mockFirebaseAuthService.isNewUser = false
        self.mockServerService.shouldSucceed = true
        
        await viewModel.signInWithGoogle()
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLogged == true)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
    }
    
    @Test
    func testSignInGoogleSuccessfulSignup() async throws {
        self.mockFirebaseAuthService.shouldSucceed = true
        // signup - new user
        self.mockFirebaseAuthService.isNewUser = true
        self.mockServerService.shouldSucceed = true
        
        await viewModel.signInWithGoogle()
        #expect(viewModel.errorMessage == nil)
        
        // signup with google is the same as a login, user enters immediately
        #expect(viewModel.isLogged == true)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
    }
}

