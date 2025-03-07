import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class RankingViewModelIntegrationTest {
    private var mockModelContainer: ModelContainer
    private var mockModelContext: ModelContext
    private var viewModel: RankingViewModel
    private var serverService: ServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    
    init() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        
        self.serverService = ServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = RankingViewModel(modelContext: container.mainContext, serverService: serverService)
        
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
    
    private func addTravel() async throws {
        let travelSearchViewModel = TravelSearchViewModel(modelContext: self.mockModelContext, serverService: self.serverService)
        
        // no user travel
        var travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        #expect(travels.count == 0)
        
        // search options
        travelSearchViewModel.departure = CityCompleterDataset(
            cityName: "Milano",
            countryName: "Italy",
            iata: "MIL",
            countryCode: "IT",
            continent: "Europe"
        )
        travelSearchViewModel.arrival = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        travelSearchViewModel.oneWay = true
        await travelSearchViewModel.computeRoutes()
        
        #expect(!travelSearchViewModel.outwardOptions.isEmpty)
        #expect(travelSearchViewModel.returnOptions.isEmpty)
        
        // select an option
        travelSearchViewModel.selectedOption = travelSearchViewModel.outwardOptions[0].segments
        // save travel
        await travelSearchViewModel.saveTravel()
        
        // 1 user travel
        travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        #expect(travels.count == 1)
    }
    
    private func confirmTravel() async throws {
        let myTravelsViewModel = MyTravelsViewModel(modelContext: self.mockModelContext, serverService: self.serverService)
        
        // get travels from server
        await myTravelsViewModel.getUserTravels()
        // check travel present
        #expect(myTravelsViewModel.travelDetailsList.count == 1)
        
        // select travel
        let travelDetails = myTravelsViewModel.travelDetailsList.first!
        myTravelsViewModel.selectedTravel = travelDetails
        let travel = travelDetails.travel
        
        #expect(travel.confirmed == false)
        
        // confirm travel
        await myTravelsViewModel.confirmTravel()
        
        // check travel confirmed
        #expect(travel.confirmed == true)
    }
    
    @Test
    func testFetchRankingsNoUser() async {
        // no user in SwiftData
        
        // fetch ranking
        await viewModel.fecthRanking()
        
        #expect(viewModel.shortDistanceRanking.isEmpty)
        #expect(viewModel.longDistanceRanking.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testFetchRankingSuccessful() async throws {
        // login
        try await loginUser()

        // add a long distance travel
        try await addTravel()
        
        // confirm travel to make it count for score
        try await confirmTravel()
        
        // fetch ranking
        await viewModel.fecthRanking()
        
        #expect(viewModel.longDistanceRanking.count == 1)
        #expect(viewModel.shortDistanceRanking.count == 1)
        #expect(viewModel.errorMessage == nil)
    }
}
