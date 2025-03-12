import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class CompleterViewModelUnitTest {
    private var mockModelContext: ModelContext
    private var mockModelContainer: ModelContainer
    private var mockServerService: MockServerService
    
    init() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContext = container.mainContext
        self.mockModelContainer = container
        
        // add travels to SwiftData
        self.mockServerService = MockServerService()
        self.mockServerService.shouldSucceed = true
        let myTravelsViewModel = MyTravelsViewModel(modelContext: mockModelContext, serverService: mockServerService)
        await myTravelsViewModel.getUserTravels()
        
        // add cities to SwiftData
        try addCitiesToSwiftData()
        // add travel to SwiftData
        try addTravelToSwiftData()
    }
    
    private func addTravelToSwiftData() throws {
        let mockTravel = Travel(travelID: 1, userID: 1)
        let mockSegment = Segment(segmentID: 1, departureID: 1, destinationID: 1, departureCity: "Milano", departureCountry: "Italy", destinationCity: "Milano", destinationCountry: "Italy", dateTime: Date.now, duration: 100, vehicle: Vehicle.car, segmentDescription: "description", price: 100, co2Emitted: 100, distance: 100, numSegment: 1, isOutward: true, travelID: 1)
        self.mockModelContext.insert(mockTravel)
        self.mockModelContext.insert(mockSegment)
        try self.mockModelContext.save()
    }
    
    private func addCitiesToSwiftData() throws {
        let cityMilano = CityCompleterDataset(
            cityName: "Milano",
            countryName: "Italy",
            iata: "MIL",
            countryCode: "IT",
            continent: "Europe"
        )
        let cityRomaIT = CityCompleterDataset(
            cityName: "Roma",
            countryName: "Italy",
            iata: "ROM",
            countryCode: "IT",
            continent: "Europe"
        )
        let cityRomaUS = CityCompleterDataset(
            cityName: "Roma",
            countryName: "United States",
            iata: "FAL",
            countryCode: "US",
            continent: "North America"
        )
        let cityParis = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        let cityNewYork = CityCompleterDataset(
            cityName: "New York",
            countryName: "United States",
            iata: "NYC",
            countryCode: "US",
            continent: "North America"
        )
        let cityMiami = CityCompleterDataset(
            cityName: "Miami",
            countryName: "United States",
            iata: "4MI",
            countryCode: "US",
            continent: "North America"
        )
        let cityMarblehead = CityCompleterDataset(
            cityName: "Marblehead",
            countryName: "United States",
            iata: "4MH",
            countryCode: "US",
            continent: "North America"
        )
        
        self.mockModelContext.insert(cityMilano)
        self.mockModelContext.insert(cityRomaIT)
        self.mockModelContext.insert(cityRomaUS)
        self.mockModelContext.insert(cityParis)
        self.mockModelContext.insert(cityNewYork)
        self.mockModelContext.insert(cityMiami)
        self.mockModelContext.insert(cityMarblehead)
        try self.mockModelContext.save()
    }
    
    @Test
    func testEmptySearchDeparture() {
        let viewModel = CompleterViewModel(modelContext: self.mockModelContext, departure: true)
        viewModel.searchText = ""
        
        let cityMilano = CityCompleterDataset(
            cityName: "Milano",
            countryName: "Italy",
            iata: "MIL",
            countryCode: "IT",
            continent: "Europe"
        )
        
        #expect(!viewModel.suggestions.isEmpty)
        #expect(viewModel.suggestions.contains(cityMilano))
    }
    
    @Test
    func testExactSearchDeparture() {
        let viewModel = CompleterViewModel(modelContext: self.mockModelContext, departure: true)
        viewModel.searchText = "Milano"
        #expect(!viewModel.suggestions.isEmpty)
        #expect(viewModel.suggestions.first?.cityName == "Milano")
    }
    
    @Test
    func testSearchRoma() {
        let viewModel = CompleterViewModel(modelContext: self.mockModelContext, departure: true)
        viewModel.searchText = "Roma"
        #expect(!viewModel.suggestions.isEmpty)
        #expect(viewModel.suggestions.first?.cityName == "Roma")
    }
    
    @Test
    func testSearchStartingLetterDeparture() {
        let viewModel = CompleterViewModel(modelContext: self.mockModelContext, departure: true)
        viewModel.searchText = "M"
        #expect(!viewModel.suggestions.isEmpty)
    }
    
    @Test
    func testSearchSubstringDeparture() {
        let viewModel = CompleterViewModel(modelContext: self.mockModelContext, departure: true)
        // should find New York
        viewModel.searchText = "y"
        #expect(!viewModel.suggestions.isEmpty)
    }
    
    @Test
    func testSearchRandomDeparture() {
        let viewModel = CompleterViewModel(modelContext: self.mockModelContext, departure: true)
        viewModel.searchText = "a"
        #expect(!viewModel.suggestions.isEmpty)
    }
    
    @Test
    func testEmptySearchDestination() {
        let viewModel = CompleterViewModel(modelContext: self.mockModelContext, departure: false)
        viewModel.searchText = ""
        #expect(viewModel.suggestions.isEmpty)
    }
    
    @Test
    func testExactSearchDestination() {
        let viewModel = CompleterViewModel(modelContext: self.mockModelContext, departure: false)
        viewModel.searchText = "Milano"
        #expect(!viewModel.suggestions.isEmpty)
        #expect(viewModel.suggestions.first?.cityName == "Milano")
    }
    
    @Test
    func testSearchStartingLetterDestination() {
        let viewModel = CompleterViewModel(modelContext: self.mockModelContext, departure: false)
        viewModel.searchText = "M"
        #expect(!viewModel.suggestions.isEmpty)
    }
    
    @Test
    func testSearchSubstringDestination() {
        let viewModel = CompleterViewModel(modelContext: self.mockModelContext, departure: false)
        // should find New York
        viewModel.searchText = "y"
        #expect(!viewModel.suggestions.isEmpty)
    }
    
    @Test
    func testSearchRandomDestination() {
        let viewModel = CompleterViewModel(modelContext: self.mockModelContext, departure: false)
        viewModel.searchText = "a"
        #expect(!viewModel.suggestions.isEmpty)
    }
}
