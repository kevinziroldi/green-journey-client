import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class AuthenticationViewModelIntegrationTest {
    private var viewModel: AuthenticationViewModel
    private var mockModelContext: ModelContext
    private var mockModelContainer: ModelContainer
    private var serverService: ServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    
    init() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = mockContainer
        self.mockModelContext = mockContainer.mainContext
        
        self.serverService = ServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = AuthenticationViewModel(modelContext: mockContainer.mainContext, serverService: serverService, firebaseAuthService: mockFirebaseAuthService)
        
        // clean database
        try await serverService.resetTestDatabase()
    }
    
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
    
    @Test
    func testSignupSuccessful() async throws {
        // fill all fields
        viewModel.email = "test@test.com"
        viewModel.password = "test_password"
        viewModel.repeatPassword = "test_password"
        viewModel.firstName = "test_name"
        viewModel.lastName = "test_name"

        // firebase auth should succeed
        self.mockFirebaseAuthService.shouldSucceed = true
        
        await viewModel.signUp()
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLogged == false)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
        #expect(viewModel.isEmailVerificationActiveSignup == true)
    }
    
    @Test
    func testSignupAndVerifyEmail() async throws {
        // signup
        viewModel.email = "test@test.com"
        viewModel.password = "test_password"
        viewModel.repeatPassword = "test_password"
        viewModel.firstName = "test_name"
        viewModel.lastName = "test_name"

        // firebase auth should succeed
        self.mockFirebaseAuthService.shouldSucceed = true
        
        await viewModel.signUp()
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLogged == false)
        
        // check SwiftData has no user
        var users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
        #expect(viewModel.isEmailVerificationActiveSignup == true)
    
        // verify email
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = true
        await viewModel.verifyEmail()
        #expect(viewModel.errorMessage == nil)
        
        #expect(viewModel.emailVerified == true)
        #expect(viewModel.isEmailVerificationActiveLogin == false)
        #expect(viewModel.isEmailVerificationActiveSignup == false)
        
        // check the user is in SwiftData
        users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
    }
    
    @Test
    func testLogout() async throws {
        // signup
        viewModel.email = "test@test.com"
        viewModel.password = "test_password"
        viewModel.repeatPassword = "test_password"
        viewModel.firstName = "test_name"
        viewModel.lastName = "test_name"

        // firebase auth should succeed
        self.mockFirebaseAuthService.shouldSucceed = true
        
        await viewModel.signUp()
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLogged == false)
        
        // check SwiftData has no user
        var users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
        #expect(viewModel.isEmailVerificationActiveSignup == true)
    
        // verify email
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = true
        await viewModel.verifyEmail()
        #expect(viewModel.errorMessage == nil)
        
        #expect(viewModel.emailVerified == true)
        #expect(viewModel.isEmailVerificationActiveLogin == false)
        #expect(viewModel.isEmailVerificationActiveSignup == false)
        
        // check the user is in SwiftData
        users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
        
        viewModel.logout()
        #expect(viewModel.isLogged == false)
        
        // check no user in SwiftData
        users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @Test
    func testLoginWrongCredentials() async {
        // no user in the database
        
        // set email and password
        viewModel.email = "test@test.com"
        viewModel.password = "test"
        
        self.mockFirebaseAuthService.shouldSucceed = false
        
        await viewModel.login()
        #expect(viewModel.isLogged == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testLoginSuccessful() async throws {
        // signup - creates the user
        viewModel.email = "test@test.com"
        viewModel.password = "test_password"
        viewModel.repeatPassword = "test_password"
        viewModel.firstName = "test_name"
        viewModel.lastName = "test_name"
        
        // firebase auth should succeed
        self.mockFirebaseAuthService.shouldSucceed = true
        
        await viewModel.signUp()
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLogged == false)
        
        // check SwiftData has no user
        var users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
        #expect(viewModel.isEmailVerificationActiveSignup == true)
        
        // verify email - already logs the user
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = true
        await viewModel.verifyEmail()
        #expect(viewModel.errorMessage == nil)
        
        #expect(viewModel.emailVerified == true)
        #expect(viewModel.isEmailVerificationActiveLogin == false)
        #expect(viewModel.isEmailVerificationActiveSignup == false)
        
        // check the user is in SwiftData
        users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
        
        // logout user
        viewModel.logout()
        #expect(viewModel.isLogged == false)
        // check no user in SwiftData
        users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
        
        // login
        // set email and password
        viewModel.email = "test@test.com"
        viewModel.password = "test"
        
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = true
        
        await viewModel.login()
        #expect(viewModel.isEmailVerificationActiveLogin == false)
        #expect(viewModel.isLogged == true)
        #expect(viewModel.errorMessage == nil)
        users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
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
        
        await viewModel.resetPassword(email: email)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.resendEmail != nil)
    }
    
    @Test
    func testSignInGoogleSignup() async throws {
        self.mockFirebaseAuthService.shouldSucceed = true
        // signup - new user
        self.mockFirebaseAuthService.isNewUser = true
        
        await viewModel.signInWithGoogle()
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLogged == true)
        
        // check user in SwiftData
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
    }
    
    @Test
    func testSignInGoogleSuccessfulLogin() async throws {
        // signup
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.isNewUser = true
        
        await viewModel.signInWithGoogle()
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLogged == true)
        
        // check user in SwiftData
        var users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
        
        // logout
        viewModel.logout()
        #expect(viewModel.isLogged == false)
        
        // check no user in SwiftData
        users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
        
        // login with google
        self.mockFirebaseAuthService.shouldSucceed = true
        // login - not new user
        self.mockFirebaseAuthService.isNewUser = false
    
        await viewModel.signInWithGoogle()
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLogged == true)
        
        // check user in SwiftData
        users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
    }
}

