import SwiftUI
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class NavigationDestinationTest {
    private var mockModelContainer: ModelContainer
    private var mockModelContext: ModelContext
    private var mockServerService: MockServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        self.mockServerService = MockServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
    }
    
    @Test
    func testNavigationDestinationEqualityAuthenticationViewModel() {
        let authenticationViewModel = AuthenticationViewModel(modelContext: mockModelContext, serverService: mockServerService, firebaseAuthService: mockFirebaseAuthService)
        
        let destination1 = NavigationDestination.SignupView(authenticationViewModel)
        let destination2 = NavigationDestination.SignupView(authenticationViewModel)
        
        #expect(destination1 == destination2)
        #expect(destination1.hashValue == destination2.hashValue)
    }

    @Test
    func testNavigationDestinationInequalityAuthenticationViewModel() {
        let authenticationViewModel1 = AuthenticationViewModel(modelContext: mockModelContext, serverService: mockServerService, firebaseAuthService: mockFirebaseAuthService)
        let authenticationViewModel2 = AuthenticationViewModel(modelContext: mockModelContext, serverService: mockServerService, firebaseAuthService: mockFirebaseAuthService)
        
        let destination1 = NavigationDestination.SignupView(authenticationViewModel1)
        let destination2 = NavigationDestination.SignupView(authenticationViewModel2)
        
        #expect(destination1 != destination2)
        #expect(destination1.hashValue != destination2.hashValue)
    }
    
    @Test
    func testNavigationDestinationEqualityTravelSearchViewModel() {
        let travelSearchViewModel = TravelSearchViewModel(modelContext: mockModelContext, serverService: mockServerService)
        
        let destination1 = NavigationDestination.OutwardOptionsView("dep", "arr", travelSearchViewModel)
        let destination2 = NavigationDestination.OutwardOptionsView("dep", "arr", travelSearchViewModel)
        
        #expect(destination1 == destination2)
        #expect(destination1.hashValue == destination2.hashValue)
    }

    @Test
    func testNavigationDestinationInequalityTravelSearchViewModel() {
        let travelSearchViewModel1 = TravelSearchViewModel(modelContext: mockModelContext, serverService: mockServerService)
        let travelSearchViewModel2 = TravelSearchViewModel(modelContext: mockModelContext, serverService: mockServerService)
        
        let destination1 = NavigationDestination.OutwardOptionsView("dep1", "arr1", travelSearchViewModel1)
        let destination2 = NavigationDestination.OutwardOptionsView("dep2", "arr2", travelSearchViewModel2)
        
        #expect(destination1 != destination2)
        #expect(destination1.hashValue != destination2.hashValue)
    }
    
    @Test
    func testNavigationDestinationEqualityMyTravelsViewModel() {
        let myTravelsViewModel = MyTravelsViewModel(modelContext: mockModelContext, serverService: mockServerService)
        
        let destination1 = NavigationDestination.TravelDetailsView(myTravelsViewModel)
        let destination2 = NavigationDestination.TravelDetailsView(myTravelsViewModel)
        
        #expect(destination1 == destination2)
        #expect(destination1.hashValue == destination2.hashValue)
    }
    
    @Test
    func testNavigationDestinationInequalityMyTravelsViewModel() {
        let myTravelsViewModel1 = MyTravelsViewModel(modelContext: mockModelContext, serverService: mockServerService)
        let myTravelsViewModel2 = MyTravelsViewModel(modelContext: mockModelContext, serverService: mockServerService)
        
        let destination1 = NavigationDestination.TravelDetailsView(myTravelsViewModel1)
        let destination2 = NavigationDestination.TravelDetailsView(myTravelsViewModel2)
        
        #expect(destination1 != destination2)
        #expect(destination1.hashValue != destination2.hashValue)
    }
    
    @Test
    func testNavigationDestinationEqualityCitiesReviewsViewModelViewModel() {
        let citiesReviewsViewModel = CitiesReviewsViewModel(modelContext: mockModelContext, serverService: mockServerService)
        
        let destination1 = NavigationDestination.AllReviewsView(citiesReviewsViewModel)
        let destination2 = NavigationDestination.AllReviewsView(citiesReviewsViewModel)
        
        #expect(destination1 == destination2)
        #expect(destination1.hashValue == destination2.hashValue)
    }
    
    @Test
    func testNavigationDestinationInequalityCitiesReviewsViewModelViewModel() {
        let citiesReviewsViewModel1 = CitiesReviewsViewModel(modelContext: mockModelContext, serverService: mockServerService)
        let citiesReviewsViewModel2 = CitiesReviewsViewModel(modelContext: mockModelContext, serverService: mockServerService)
        
        let destination1 = NavigationDestination.AllReviewsView(citiesReviewsViewModel1)
        let destination2 = NavigationDestination.AllReviewsView(citiesReviewsViewModel2)
        
        #expect(destination1 != destination2)
        #expect(destination1.hashValue != destination2.hashValue)
    }
    

}
