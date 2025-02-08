import SwiftData
import Testing

@testable import GreenJourney

struct RankingViewModelTest {
    private var viewModel: RankingViewModel!
    private var mockServerService: MockServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    
    @MainActor
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockServerService = MockServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = RankingViewModel(modelContext: container.mainContext, serverService: mockServerService)
    }    
}
