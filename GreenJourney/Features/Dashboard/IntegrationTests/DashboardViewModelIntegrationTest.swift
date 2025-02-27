import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class DashboardViewModelIntegrationTest {
    private var mockModelContext: ModelContext
    private var mockModelContainer: ModelContainer
    private var serverService: ServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    private var viewModel: DashboardViewModel
    
    init() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContext = container.mainContext
        self.mockModelContainer = container
        
        self.serverService = ServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = DashboardViewModel(modelContext: mockModelContext)
        
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
        travelSearchViewModel.selectedOption = travelSearchViewModel.outwardOptions[0]
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
    func testGetUserTravels() async throws {
        // login
        try await loginUser()
        // add travel
        try await addTravel()
        // confirm travel
        try await confirmTravel()
        
        // get travels from server
        viewModel.getUserTravels()
        
        // check values
        #expect(viewModel.treesPlanted == 0)
        #expect(viewModel.co2Compensated == 0)
        #expect(viewModel.totalDistance > 0)
        #expect(viewModel.visitedContinents == 1)
        let currYear = Calendar.current.component(.year, from: Date())
        for distance in viewModel.distances {
            if distance.key < currYear {
                #expect(distance.value == 0)
            } else {
                #expect(distance.value > 0)
            }
        }
        for tripsMade in viewModel.tripsMade {
            if tripsMade.key < currYear {
                #expect(tripsMade.value == 0)
            } else {
                #expect(tripsMade.value == 1)
            }
        }
        #expect(viewModel.totalTripsMade == 1)
    }
}
