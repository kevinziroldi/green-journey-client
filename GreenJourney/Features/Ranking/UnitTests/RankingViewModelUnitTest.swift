import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class RankingViewModelUnitTest {
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
    func testGetUserFromServerFails() async throws {
        // set server
        self.mockServerService.shouldSucceed = false
        
        // call method
        await viewModel.getUserFromServer()
        
        // check values present
        #expect(viewModel.badges.count == 0)
        #expect(viewModel.shortDistanceScore == 0)
        #expect(viewModel.longDistanceScore == 0)
        
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
    }
    
    @Test
    func testGetUserFromServerUserNotPresent() async throws {
        // set server
        self.mockServerService.shouldSucceed = true
        
        // call method
        await viewModel.getUserFromServer()
        
        // check values present
        #expect(viewModel.badges.count == 3)
        #expect(viewModel.badges.contains(Badge.badgeDistanceLow))
        #expect(viewModel.badges.contains(Badge.badgeCompensationHigh))
        #expect(viewModel.badges.contains(Badge.badgeTravelsNumberMid))
        #expect(viewModel.shortDistanceScore == 50)
        #expect(viewModel.longDistanceScore == 100)
        
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
        #expect(users.first!.userID == 1)
    }
    
    @Test
    func testGetUserFromServerUserAlreadyPresent() async throws {
        // add a user to SwiftData
        let user = User(
            userID: 2,
            firstName: "User2",
            lastName: "User2",
            firebaseUID: "User2",
            scoreShortDistance: 10,
            scoreLongDistance: 10
        )
        mockModelContext.insert(user)
        try mockModelContext.save()
        
        // set server
        self.mockServerService.shouldSucceed = true
        
        // call method
        await viewModel.getUserFromServer()
        
        // check values present
        #expect(viewModel.badges.count == 3)
        #expect(viewModel.badges.contains(Badge.badgeDistanceLow))
        #expect(viewModel.badges.contains(Badge.badgeCompensationHigh))
        #expect(viewModel.badges.contains(Badge.badgeTravelsNumberMid))
        #expect(viewModel.shortDistanceScore == 50)
        #expect(viewModel.longDistanceScore == 100)
        
        let users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
        #expect(users.first!.userID == 1)
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
        #expect(durationString == "1 y, 0 m")
    }
    
    @Test
    func testComputeTotalDurationOneMonthOneDay() {
        let durationOneMontOneDay = 3600 * 1000000000 * 24 * 30 + 3600 * 1000000000 * 24
        let durationString = viewModel.computeTotalDuration(duration: durationOneMontOneDay)
        #expect(durationString == "1 m, 1 d")
    }
    
    @Test
    func testComputeTotalDurationFiveDaysOneHourOneMinute() {
        let duration = 3600 * 1000000000 * 24 * 5 + 3600 * 1000000000 + 60 * 1000000000
        let durationString = viewModel.computeTotalDuration(duration: duration)
        #expect(durationString == "5 d, 1 h")
    }
    
    @Test
    func testComputeTotalDurationOneHourTwoMinutesTenSeconds() {
        let duration = 3600 * 1000000000 + 2 * 60 * 1000000000 + 10 * 1000000000
        let durationString = viewModel.computeTotalDuration(duration: duration)
        #expect(durationString == "1 h, 2 min")
    }
}
