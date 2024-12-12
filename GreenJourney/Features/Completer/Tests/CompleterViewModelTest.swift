import SwiftData
import Testing

@testable import GreenJourney

struct CompleterViewModelTest {
    private var viewModel: CompleterViewModel!
    
    @MainActor
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.viewModel = CompleterViewModel(modelContext: container.mainContext)
    }
    
}
