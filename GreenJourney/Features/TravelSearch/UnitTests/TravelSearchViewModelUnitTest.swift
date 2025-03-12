import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class TravelSearchViewModelUnitTest {
    private var viewModel: TravelSearchViewModel
    private var mockServerService: MockServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    private var mockModelContainer: ModelContainer
    private var mockModelContext: ModelContext
    
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        self.mockServerService = MockServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = TravelSearchViewModel(modelContext: container.mainContext, serverService: mockServerService)
    }
    
    private func addUserToSwiftData() throws {
        let mockUser = User(
            userID: 53,
            firstName: "John",
            lastName: "Doe",
            firebaseUID: "firebase_uid",
            scoreShortDistance: 50,
            scoreLongDistance: 50
        )
        self.mockModelContext.insert(mockUser)
        try self.mockModelContext.save()
    }
    
    private func addTravelsToSwiftData() throws {
        let mockTravel = Travel(travelID: 1, userID: 53)
        let mockSegment = Segment(
            segmentID: 1,
            departureID: 1,
            destinationID: 2,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 0,
            vehicle: Vehicle.car,
            segmentDescription: "",
            price: 0,
            co2Emitted: 0,
            distance: 0,
            numSegment: 1,
            isOutward: true,
            travelID: 1
        )
        
        self.mockModelContext.insert(mockTravel)
        self.mockModelContext.insert(mockSegment)
        try self.mockModelContext.save()
    }
    
    @Test
    func testComputeRoutesServerFailure() async {
        // set service
        self.mockServerService.shouldSucceed = false
        
        await viewModel.computeRoutes()
        
        #expect(viewModel.outwardOptions.isEmpty)
        #expect(viewModel.returnOptions.isEmpty)
        #expect(viewModel.selectedOption.isEmpty)
    }
    
    @Test
    func testComputeRoutesOneWay() async {
        // set service
        self.mockServerService.shouldSucceed = true
        
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        #expect(!viewModel.outwardOptions.isEmpty)
        #expect(viewModel.returnOptions.isEmpty)
    }
    
    @Test
    func testComputeRoutesTwoWays() async {
        // set service
        self.mockServerService.shouldSucceed = true
        
        viewModel.oneWay = false
        await viewModel.computeRoutes()
        
        #expect(!viewModel.outwardOptions.isEmpty)
        #expect(!viewModel.returnOptions.isEmpty)
    }
    
    @Test
    func testComputeRoutesMultipleTimes() async {
        // set service
        self.mockServerService.shouldSucceed = true
        
        viewModel.oneWay = false
        await viewModel.computeRoutes()
        
        #expect(!viewModel.outwardOptions.isEmpty)
        #expect(!viewModel.returnOptions.isEmpty)
        
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        #expect(!viewModel.outwardOptions.isEmpty)
        #expect(viewModel.returnOptions.isEmpty)
    }
    
    @Test
    func testSaveTravelNoUser() async throws {
        // add travel
        try addTravelsToSwiftData()
        // no user in SwiftData
        
        // server should succeed
        self.mockServerService.shouldSucceed = true
    
        // compute routes
        viewModel.oneWay = true
        await viewModel.computeRoutes()
    
        // select options
        viewModel.selectedOption = viewModel.outwardOptions[0].segments
        
        await viewModel.saveTravel()
        
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        for travel in travels {
            // mock server service returns a travel with id 999
            #expect(travel.travelID != 999)
        }
    }
    
    @Test
    func testSaveTravelNoSelectedOption() async throws {
        // add travel and user
        try addTravelsToSwiftData()
        try addUserToSwiftData()
        
        // server should succeed
        self.mockServerService.shouldSucceed = true
    
        // compute routes
        viewModel.oneWay = true
        await viewModel.computeRoutes()
    
        // no select option
        await viewModel.saveTravel()
        
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        for travel in travels {
            // mock server service returns a travel with id 999
            #expect(travel.travelID != 999)
        }
    }
    
    @Test
    func testSaveTravelServerFail() async throws {
        // add travel and user
        try addTravelsToSwiftData()
        try addUserToSwiftData()
        
        // server should succeed for compute routes
        self.mockServerService.shouldSucceed = true
    
        // compute routes
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        // server should fail for save travel
        self.mockServerService.shouldSucceed = false

        // select options
        viewModel.selectedOption = viewModel.outwardOptions[0].segments
        // save travel
        await viewModel.saveTravel()
        
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        for travel in travels {
            // mock server service returns a travel with id 999
            #expect(travel.travelID != 999)
        }
    }
    
    @Test
    func testSaveTravelServerSucceessful() async throws {
        // add travel and user
        try addTravelsToSwiftData()
        try addUserToSwiftData()
        
        // server should succeed
        self.mockServerService.shouldSucceed = true
    
        // compute routes
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        // select options
        viewModel.selectedOption = viewModel.outwardOptions[0].segments
        // save travel
        await viewModel.saveTravel()
        
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        var found = false
        for travel in travels {
            // mock server service returns a travel with id 999
            if travel.travelID == 999 {
                found = true
                break
            }
        }
        #expect(found)
    }
    
    @Test
    func testResetParameters() async {
        // set a departure
        let cityDeparture = CityCompleterDataset(
            cityName: "City1",
            countryName: "City1",
            iata: "City1",
            countryCode: "City1",
            continent: "City1"
        )
        viewModel.departure = cityDeparture
        // set an arrival
        let cityArrival = CityCompleterDataset(
            cityName: "City2",
            countryName: "City2",
            iata: "City2",
            countryCode: "City2",
            continent: "City2"
        )
        viewModel.arrival = cityArrival
        
        // set date
        viewModel.datePicked = Date.now
        
        // compute a route
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = false
        
        await viewModel.computeRoutes()
        #expect(!viewModel.outwardOptions.isEmpty)
        #expect(!viewModel.returnOptions.isEmpty)
        
        // select an option
        viewModel.selectedOption = viewModel.outwardOptions[0].segments
        
        // select a predicted city
        viewModel.predictedCities = [cityArrival]
        
        // reset
        viewModel.resetParameters()
        
        // check effective reset
        
        #expect(viewModel.arrival == CityCompleterDataset())
        #expect(viewModel.departure == CityCompleterDataset())
        #expect(viewModel.selectedOption.isEmpty)
        #expect(viewModel.outwardOptions.isEmpty)
        #expect(viewModel.returnOptions.isEmpty)
        #expect(viewModel.predictedCities.isEmpty)
    }
}
