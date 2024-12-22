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
}
