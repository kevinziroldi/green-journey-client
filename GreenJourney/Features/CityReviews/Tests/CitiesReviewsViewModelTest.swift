import SwiftData
import Testing

@testable import GreenJourney

struct CitiesReviewsViewModelTest {
    private var mockModelContext: ModelContext
    private var viewModel: CitiesReviewsViewModel!
    
    @MainActor
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContext = mockContainer.mainContext
        self.viewModel = CitiesReviewsViewModel(modelContext: self.mockModelContext)
    }

    @Test
    func testReset() {
        viewModel.bestCitiesReviewElements.append(CityReviewElement())
        viewModel.bestCities.append(CityCompleterDataset())
        viewModel.searchedCity = CityCompleterDataset(city: "Paris", countryName: "France", iata: "PAR", continent: "Europe", countryCode: "FR")
        viewModel.searchedCityReviewElement = CityReviewElement()
        viewModel.searchedCityAvailable = true
        viewModel.selectedCity = CityCompleterDataset()
        viewModel.selectedCityReviewElement = CityReviewElement()
        
        viewModel.resetParameters()
        
        #expect(viewModel.bestCitiesReviewElements.isEmpty)
        #expect(viewModel.bestCities.isEmpty)
        #expect(viewModel.searchedCity == CityCompleterDataset())
        #expect(viewModel.searchedCityReviewElement == nil)
        #expect(viewModel.searchedCityAvailable == false)
        #expect(viewModel.selectedCity == nil)
        #expect(viewModel.selectedCityReviewElement == nil)
    }
    
}
