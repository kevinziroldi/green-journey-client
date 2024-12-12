import SwiftData
import Testing

@testable import GreenJourney

struct RankingViewModelTest {
    private var viewModel: RankingViewModel!
    
    @MainActor
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.viewModel = RankingViewModel(modelContext: container.mainContext)
    }    
}
