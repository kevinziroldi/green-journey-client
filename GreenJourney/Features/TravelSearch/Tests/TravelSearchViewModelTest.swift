import SwiftData
import Testing

@testable import GreenJourney

struct TravelSearchViewModelTest {
    private var viewModel: TravelSearchViewModel!
    
    @MainActor
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.viewModel = TravelSearchViewModel(modelContext: container.mainContext)
    }    
}
