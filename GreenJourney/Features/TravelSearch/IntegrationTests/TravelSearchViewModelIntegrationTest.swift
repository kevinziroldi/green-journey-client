import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class TravelSearchViewModelIntegrationTest {
    private var viewModel: TravelSearchViewModel
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
        self.viewModel = TravelSearchViewModel(modelContext: container.mainContext, serverService: serverService)
        
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
    func testComputeRoutesOneWay() async {
        // set departure and destination
        viewModel.departure = CityCompleterDataset(
            cityName: "Milano",
            countryName: "Italy",
            iata: "MIL",
            countryCode: "IT",
            continent: "Europe"
        )
        viewModel.arrival = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        viewModel.oneWay = true
        
        await viewModel.computeRoutes()
        
        #expect(!viewModel.outwardOptions.isEmpty)
        #expect(viewModel.returnOptions.isEmpty)
    }
    
    @Test
    func testComputeRoutesTwoWays() async {
        // set departure and destination
        viewModel.departure = CityCompleterDataset(
            cityName: "Milano",
            countryName: "Italy",
            iata: "MIL",
            countryCode: "IT",
            continent: "Europe"
        )
        viewModel.arrival = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        viewModel.oneWay = false
        
        await viewModel.computeRoutes()
        
        #expect(!viewModel.outwardOptions.isEmpty)
        #expect(!viewModel.returnOptions.isEmpty)
    }
    
    @Test
    func testSaveTravelNoSelectedOption() async throws {
        // add travel and user
        try await loginUser()
        
        // no option selected
        #expect(viewModel.selectedOption.isEmpty)
    
        // no select option
        await viewModel.saveTravel()
        
        // no user travel
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        #expect(travels.count == 0)
    }
    
    @Test
    func testSaveTravelWithSelectedOption() async throws {
        // add travel and user
        try await loginUser()
        
        // no user travel
        var travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        #expect(travels.count == 0)
        
        // search options
        viewModel.departure = CityCompleterDataset(
            cityName: "Milano",
            countryName: "Italy",
            iata: "MIL",
            countryCode: "IT",
            continent: "Europe"
        )
        viewModel.arrival = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        #expect(!viewModel.outwardOptions.isEmpty)
        #expect(viewModel.returnOptions.isEmpty)
        
        // select an option
        viewModel.selectedOption = viewModel.outwardOptions[0].segments
        // save travel
        await viewModel.saveTravel()
        
        // 1 user travel
        travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        #expect(travels.count == 1)
    }
}
