import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class MyTravelsViewModelIntegrationTest {
    private var viewModel: MyTravelsViewModel
    private var mockModelContainer: ModelContainer
    private var mockModelContext: ModelContext
    private var serverService: ServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    
    init() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        self.serverService = ServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = MyTravelsViewModel(modelContext: container.mainContext, serverService: serverService)
        
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
    
    @Test
    func testGetUserTravels() async throws {
        // login user
        try await loginUser()
        
        // add a travel
        try await addTravel()
        
        // remove travels from SwiftData
        var travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        let segments = try mockModelContext.fetch(FetchDescriptor<Segment>())
        for travel in travels {
            mockModelContext.delete(travel)
        }
        for segment in segments {
            mockModelContext.delete(segment)
        }
        try mockModelContext.save()
        
        // get travels from server
        await viewModel.getUserTravels()
        
        travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        #expect(travels.count == 1)
    }
    
    @Test
    func testConfirmTravel() async throws {
        // login user
        try await loginUser()
        
        // add a travel
        try await addTravel()
        // check travel present in SwiftData
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        #expect(travels.count == 1)
        
        // get travels from server
        await viewModel.getUserTravels()
        // check travel present
        #expect(viewModel.travelDetailsList.count == 1)
        
        // select travel
        let travelDetails = viewModel.travelDetailsList.first!
        viewModel.selectedTravel = travelDetails
        let travel = travelDetails.travel
        #expect(travel.confirmed == false)
        
        // confirm travel
        await viewModel.confirmTravel()
        
        // check travel confirmed
        #expect(travel.confirmed == true)
    }
    
    @Test
    func testCompensateCo2TravelNotConfirmed() async throws {
        // login user
        try await loginUser()
        
        // add a travel
        try await addTravel()
        // check travel present in SwiftData
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        #expect(travels.count == 1)
        
        // get travels from server
        await viewModel.getUserTravels()
        // check travel present
        #expect(viewModel.travelDetailsList.count == 1)
        
        // select travel
        let travelDetails = viewModel.travelDetailsList.first!
        viewModel.selectedTravel = travelDetails
        viewModel.compensatedPrice = 1
        
        // save travel data
        let travelId = viewModel.selectedTravel?.travel.travelID!
        let co2Compensated = viewModel.selectedTravel!.travel.CO2Compensated
        
        // initialize server and compensate co2
        await viewModel.compensateCO2()
        
        // check co2 compensated
        for td in viewModel.travelDetailsList {
            if td.travel.travelID == travelId {
                #expect(td.travel.CO2Compensated == co2Compensated)
            }
        }
    }
    
    @Test
    func testCompensateCo2TravelConfirmed() async throws {
        // login user
        try await loginUser()
        
        // add a travel
        try await addTravel()
        // check travel present in SwiftData
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        #expect(travels.count == 1)
        
        // get travels from server
        await viewModel.getUserTravels()
        // check travel present
        #expect(viewModel.travelDetailsList.count == 1)
        
        // select travel
        let travelDetails = viewModel.travelDetailsList.first!
        viewModel.selectedTravel = travelDetails
        let travel = travelDetails.travel
        #expect(travel.confirmed == false)
        
        // confirm travel
        await viewModel.confirmTravel()
        
        // check travel confirmed
        #expect(travel.confirmed == true)
        
        viewModel.selectedTravel = travelDetails
        viewModel.compensatedPrice = 1
        
        // save travel data
        let travelId = viewModel.selectedTravel?.travel.travelID!
        let co2Compensated = viewModel.selectedTravel!.travel.CO2Compensated
        let compensatedPrice = viewModel.compensatedPrice
        
        // initialize server and compensate co2
        await viewModel.compensateCO2()
        
        // check co2 compensated
        for td in viewModel.travelDetailsList {
            if td.travel.travelID == travelId {
                let newCo2Compensated = co2CompensatedPerEuro * Double(compensatedPrice)
                #expect(td.travel.CO2Compensated == co2Compensated + newCo2Compensated)
            }
        }
    }
    
    @Test
    func testDeleteTravel() async throws {
        // login user
        try await loginUser()
        
        // add a travel
        try await addTravel()
        // check travel present in SwiftData
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        #expect(travels.count == 1)
        
        // get travels from server
        await viewModel.getUserTravels()
        // check travel present
        #expect(viewModel.travelDetailsList.count == 1)
        
        // select travel
        let travelDetails = viewModel.travelDetailsList.first!
        viewModel.selectedTravel = travelDetails
        let travel = travelDetails.travel
        
        // delete travel
        await viewModel.deleteTravel()
        
        // check travel not present anymore
        for td in viewModel.travelDetailsList {
            #expect(td.travel.travelID != travel.travelID)
        }
    }
}
