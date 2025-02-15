import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class TravelSearchViewModelTest {
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
        viewModel.selectedOption = viewModel.outwardOptions[0]
        
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
        viewModel.selectedOption = viewModel.outwardOptions[0]
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
        viewModel.selectedOption = viewModel.outwardOptions[0]
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
    func testComputeCo2EmittedNoSegments() async {
        let co2Emitted = viewModel.computeCo2Emitted([])
        #expect(co2Emitted == 0)
    }
    
    @Test
    func testComputeCo2EmittedWithSegments() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[1]
        
        let co2Emitted = viewModel.computeCo2Emitted(option)
        #expect(co2Emitted == 170.40000000000001)
    }
    
    @Test
    func testComputeTotalPriceNoSegments() async {
        let price = viewModel.computeTotalPrice([])
        #expect(price == 0)
    }
    
    @Test
    func testComputeTotalPriceBike() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[0]
        let price = viewModel.computeTotalPrice(option)
        #expect(price == 0)
    }
   
    @Test
    func testComputeTotalPriceMultipleSegments() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[2]
        let price = viewModel.computeTotalPrice(option)
        let expectedPrice = 8.3599999999999994 + 28.050000000000001 + 15.619999999999999 + 48.18
        #expect(price == expectedPrice)
    }
    
    @Test
    func testComputeTotalDurationNoSegments() async {
        let totalDuration = viewModel.computeTotalDuration([])
        #expect(totalDuration == "0 h, 0 min")
    }
    
    @Test
    func testComputeTotalDurationOneSegment() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[1]
        let duration = viewModel.computeTotalDuration(option)
        let expectedDuration = "8 h, 45 min"
        #expect(duration == expectedDuration)
    }
    
    @Test
    func testComputeTotalDurationLongSegment() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[6]
        let duration = viewModel.computeTotalDuration(option)
        let expectedDuration = "5 d, 21 h, 40 min"
        #expect(duration == expectedDuration)
    }
    
    @Test
    func testGetOptionDepartureNoSegments() async {
        let departure = viewModel.getOptionDeparture([])
        #expect(departure == "")
    }
    
    @Test
    func testGetOptionDeparture() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[0]
        let departure = viewModel.getOptionDeparture(option)
        let expectedDeparture = "Milano"
        #expect(departure == expectedDeparture)
    }
    
    @Test
    func testGetOptionDestinationNoSegments() async {
        let departure = viewModel.getOptionDestination([])
        #expect(departure == "")
    }
    
    @Test
    func testGetOptionDestination() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[0]
        let destination = viewModel.getOptionDestination(option)
        let expectedDestination = "Paris"
        #expect(destination == expectedDestination)
    }
    
    @Test
    func testGetVehicleCar() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[1]
        
        let vehicle = viewModel.findVehicle(option)
        #expect(vehicle == "car")
    }
    
    @Test
    func testGetVehicleBike() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[0]
        
        let vehicle = viewModel.findVehicle(option)
        #expect(vehicle == "bicycle")
    }
    
    @Test
    func testGetVehicleTrain() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[2]
        
        let vehicle = viewModel.findVehicle(option)
        #expect(vehicle == "tram")
    }
    
    @Test
    func testGetVehiclePlane() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[3]
        
        let vehicle = viewModel.findVehicle(option)
        #expect(vehicle == "airplane")
    }
    
    @Test
    func testGetVehicleBus() async {
        self.mockServerService.shouldSucceed = true
        viewModel.oneWay = true
        await viewModel.computeRoutes()
        
        let option = viewModel.outwardOptions[6]
        
        let vehicle = viewModel.findVehicle(option)
        #expect(vehicle == "bus")
    }
    
    @Test
    func testGetVehicleNoSegments() async {
        let vehicle = viewModel.findVehicle([])
        #expect(vehicle == "")
    }
}
