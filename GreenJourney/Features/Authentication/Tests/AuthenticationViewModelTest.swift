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
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testLoginSuccessfulEmailNotVerified() async {
        // set email and password
        viewModel.email = "test@test.com"
        viewModel.password = "test"
    
        self.mockFirebaseAuthService.signInShouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = false
        
        await viewModel.login()
        
        #expect(viewModel.isEmailVerificationActiveLogin)
    }
    
    @MainActor
    @Test
    func testLoginSuccessfulEmailVerified() async throws {
        // set email and password
        viewModel.email = "test@test.com"
        viewModel.password = "test"
    
        self.mockFirebaseAuthService.signInShouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = true
        
        await viewModel.login()
        
        #expect(viewModel.isEmailVerificationActiveLogin == false)
        #expect(viewModel.errorMessage == nil)
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
    }
}
