import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class RankingViewModelTest {
    private var mockModelContainer: ModelContainer
    private var mockModelContext: ModelContext
    private var viewModel: RankingViewModel
    private var mockServerService: MockServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        
        self.mockServerService = MockServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = RankingViewModel(modelContext: container.mainContext, serverService: mockServerService)
    }
    
    private func addUserToSwiftData() throws {
        let mockUser = User(
            userID: 53,
            firstName: "John",
            lastName: "Doe",
            firebaseUID: "firebase_uid",
            scoreShortDistance: 50,
            scoreLongDistance: 50
        )
        self.mockModelContext.insert(mockUser)
        try self.mockModelContext.save()
    }
    
    @Test
    func testFetchRankingsNoUser() async {
        // no user in SwiftData
        self.mockServerService.shouldSucceed = true
        
        await viewModel.fecthRanking()
        
        #expect(viewModel.shortDistanceRanking.isEmpty)
        #expect(viewModel.longDistanceRanking.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testFetchRankingServerFails() async throws {
        // add user to SwiftData
        try addUserToSwiftData()
        
        self.mockServerService.shouldSucceed = false
        await viewModel.fecthRanking()
        
        #expect(viewModel.shortDistanceRanking.isEmpty)
        #expect(viewModel.longDistanceRanking.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testFetchRankingSuccessful() async throws {
        // add user to SwiftData
        try addUserToSwiftData()
        
        self.mockServerService.shouldSucceed = true
        await viewModel.fecthRanking()
        
        #expect(viewModel.longDistanceRanking.count == 11)
        #expect(viewModel.shortDistanceRanking.count == 3)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test
    func testComputeTotalDurationZero() {
        let durationString = viewModel.computeTotalDuration(duration: 0)
        #expect(durationString == "0 h, 0 min")
    }
    
    @Test
    func testComputeTotalDurationYear() {
        let durationYear = 3600 * 1000000000 * 24 * 30 * 12
        let durationString = viewModel.computeTotalDuration(duration: durationYear)
        #expect(durationString == "1 y, 0 m, 0 d, 0 h, 0 min")
    }
    
    @Test
    func testComputeTotalDurationOneMonthOneDay() {
        let durationOneMontOneDay = 3600 * 1000000000 * 24 * 30 + 3600 * 1000000000 * 24
        let durationString = viewModel.computeTotalDuration(duration: durationOneMontOneDay)
        #expect(durationString == "1 m, 1 d, 0 h, 0 min")
    }
    
    @Test
    func testComputeTotalDurationFiveDaysOneHourOneMinute() {
        let duration = 3600 * 1000000000 * 24 * 5 + 3600 * 1000000000 + 60 * 1000000000
        let durationString = viewModel.computeTotalDuration(duration: duration)
        #expect(durationString == "5 d, 1 h, 1 min")
    }
    
    @Test
    func testComputeTotalDurationOneHourTwoMinutesTenSeconds() {
        let duration = 3600 * 1000000000 + 2 * 60 * 1000000000 + 10 * 1000000000
        let durationString = viewModel.computeTotalDuration(duration: duration)
        #expect(durationString == "1 h, 2 min")
    }
}
