import SwiftData
import Testing

@testable import GreenJourney

struct UserPreferencesViewModelTest {
    private var viewModel: UserPreferencesViewModel!
    
    @MainActor
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.viewModel = UserPreferencesViewModel(modelContext: container.mainContext)
    }    
}
