import SwiftData
import Testing

@testable import GreenJourney

struct AuthenticationViewModelTest {
    private var viewModel: AuthenticationViewModel
    private var mockModelContext: ModelContext
    private var mockModelContainer: ModelContainer
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
    @MainActor
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = mockContainer
        self.mockModelContext = mockContainer.mainContext
        self.viewModel = AuthenticationViewModel(modelContext: mockContainer.mainContext)
        self.firebaseAuthService = ServiceFactory.shared.firebaseAuthService
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
    func testLoginSuccessful() async {
        // set email and password
        viewModel.email = "test@test.com"
        viewModel.password = "test"
    
        await viewModel.login()
    }
    
}
