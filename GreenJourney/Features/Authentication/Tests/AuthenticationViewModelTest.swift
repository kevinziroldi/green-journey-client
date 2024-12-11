import SwiftData
import Testing

@testable import GreenJourney

struct AuthenticationViewModelTest {
    private var viewModel: AuthenticationViewModel!
    
    @MainActor
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.viewModel = AuthenticationViewModel(modelContext: container.mainContext)
    }
    
    /*
    @Test func testAdd() {
        let res = viewModel.add(2, 3)
        #expect(res == 5)
    }
    */
}
