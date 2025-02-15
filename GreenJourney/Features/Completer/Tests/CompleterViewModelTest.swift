import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class CompleterViewModelTest {
    private var mockModelContext: ModelContext
    private var mockModelContainer: ModelContainer
    private var viewModel: CompleterViewModel
    
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.viewModel = CompleterViewModel(modelContext: container.mainContext)
        self.mockModelContext = container.mainContext
        self.mockModelContainer = container
        
        try addCitiesToSwiftData()
    }
    
    func addCitiesToSwiftData() throws {
        let cityMilan = CityCompleterDataset(
            cityName: "Milan",
            countryName: "Italy",
            iata: "MIL",
            countryCode: "IT",
            continent: "Europe"
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
        
        self.mockModelContext.insert(cityMilan)
        self.mockModelContext.insert(cityParis)
        self.mockModelContext.insert(cityNewYork)
        self.mockModelContext.insert(cityMiami)
        self.mockModelContext.insert(cityMarblehead)
        try self.mockModelContext.save()
    }
    
    @Test
    func testEmptySearch() {
        viewModel.searchText = ""
        #expect(viewModel.suggestions.isEmpty)
    }
    
    @Test
    func testExactSearch() {
        viewModel.searchText = "Milan"
        #expect(!viewModel.suggestions.isEmpty)
        #expect(viewModel.suggestions.first?.cityName == "Milan")
    }
    
    @Test
    func testSearchStartingLetter() {
        viewModel.searchText = "M"
        #expect(!viewModel.suggestions.isEmpty)
    }
    
    @Test
    func testSearchSubstring() {
        // should find New York
        viewModel.searchText = "y"
        #expect(!viewModel.suggestions.isEmpty)
    }
    
    @Test
    func testSearchRandom() {
        viewModel.searchText = "a"
        #expect(!viewModel.suggestions.isEmpty)
    }
}
