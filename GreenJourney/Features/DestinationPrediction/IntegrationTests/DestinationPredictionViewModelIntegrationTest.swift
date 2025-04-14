import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class DestinationPredictionViewModelIntegrationTest {
    private var viewModel: DestinationPredictionViewModel
    private var mockModelContext: ModelContext
    private var mockModelContainer: ModelContainer
    private var serverService: ServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    
    init() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.viewModel = DestinationPredictionViewModel(modelContext: container.mainContext)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        
        self.serverService = ServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        
        // clean database
        try await serverService.resetTestDatabase()
    }
    
    private func addVisitedCitiesFeaturesToSwiftData() throws {
        let cityFeatureParis = CityFeatures(
            id: 55,
            iata: "PAR",
            countryCode: "FR",
            cityName: "Paris",
            countryName: "France",
            population: 11060000.0,
            capital: true,
            averageTemperature: 22.0219696969697,
            continent: "Europe",
            livingCost: 3.664,
            travelConnectivity: 10.0,
            safety: 6.2465,
            healthcare: 8.207666666666666,
            education: 7.085,
            economy: 4.2045,
            internetAccess: 9.716,
            outdoors: 4.433
        )
        
        self.mockModelContext.insert(cityFeatureParis)
        try self.mockModelContext.save()
    }
    
    private func addNewCitiesFeaturesToSwiftData() throws {
        let cityFeatureRome = CityFeatures(
            id: 69,
            iata: "ROM",
            countryCode: "IT",
            cityName: "Rome",
            countryName: "Italy",
            population: 2748109.0,
            capital: true,
            averageTemperature: 30.3587786259542,
            continent: "Europe",
            livingCost: 5.323,
            travelConnectivity: 6.4335,
            safety: 6.604500000000001,
            healthcare: 7.863666666666665,
            education: 4.157000000000001,
            economy: 3.3625,
            internetAccess: 4.491,
            outdoors: 6.396000000000001
        )
        let cityFeatureVienna = CityFeatures(
            id: 71,
            iata: "VIE",
            countryCode: "AT",
            cityName: "Vienna",
            countryName: "Austria",
            population: 2223236.0,
            capital: true,
            averageTemperature: 25.450381679389317,
            continent: "Europe",
            livingCost: 5.111,
            travelConnectivity: 8.0315,
            safety: 8.5965,
            healthcare: 8.198,
            education: 4.854500000000001,
            economy: 4.663,
            internetAccess: 6.173,
            outdoors: 5.294499999999999
        )
        let cityFeatureLondon = CityFeatures(
            id: 51,
            iata: "LON",
            countryCode: "GB",
            cityName: "London",
            countryName: "United Kingdom",
            population: 11262000.0,
            capital: true,
            averageTemperature: 19.955384615384613,
            continent: "Europe",
            livingCost: 3.94,
            travelConnectivity: 9.4025,
            safety: 7.243500000000001,
            healthcare: 8.017999999999999,
            education: 9.027,
            economy: 5.438,
            internetAccess: 5.8455,
            outdoors: 5.374499999999999
        )
        self.mockModelContext.insert(cityFeatureRome)
        self.mockModelContext.insert(cityFeatureVienna)
        self.mockModelContext.insert(cityFeatureLondon)
        try self.mockModelContext.save()
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
    func testPredictionAllVisited() async throws {
        // login
        try await loginUser()
        // add travel
        try await addTravel()
        // confirm travel
        try await confirmTravel()
        
        // add only visited cities
        try addVisitedCitiesFeaturesToSwiftData()
        
        viewModel.getRecommendation()
        #expect(viewModel.predictedCities.count > 0)
    }
    
    @Test
    func testPredictionSomeNotVisited() async throws{
        // login
        try await loginUser()
        // add travel
        try await addTravel()
        // confirm travel
        try await confirmTravel()
        
        // add both visited and non visited cities
        try addVisitedCitiesFeaturesToSwiftData()
        try addNewCitiesFeaturesToSwiftData()
        
        viewModel.getRecommendation()
        #expect(viewModel.predictedCities.count > 0)
    }
    
    @Test
    func testPredictionNoCities() async throws {
        // login
        try await loginUser()
        // add travel
        try await addTravel()
        // confirm travel
        try await confirmTravel()
        
        viewModel.getRecommendation()
        #expect(viewModel.predictedCities.count == 0)
    }
}
