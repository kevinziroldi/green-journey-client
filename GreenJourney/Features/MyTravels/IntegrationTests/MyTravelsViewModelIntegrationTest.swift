import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class MyTravelsViewModelIntegrationTest {
    private var viewModel: MyTravelsViewModel
    private var mockModelContainer: ModelContainer
    private var mockModelContext: ModelContext
    private var serverService: ServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        self.serverService = ServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = MyTravelsViewModel(modelContext: container.mainContext, serverService: serverService)
    }
    
    @Test
    func testGetUserTravels() async throws {
        await viewModel.getUserTravels()
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        let segments = try mockModelContext.fetch(FetchDescriptor<Segment>())
        #expect(travels.count > 0)
        #expect(segments.count > 0)
        #expect(viewModel.travelDetailsList.count > 0)
    }
}
