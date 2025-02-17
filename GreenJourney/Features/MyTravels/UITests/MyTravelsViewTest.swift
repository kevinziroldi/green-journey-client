import XCTest

@testable import GreenJourney

class MyTravelsUITests: XCTestCase {
    let app = XCUIApplication()
    
    private var mockModelContainer: ModelContainer
    private var mockModelContext: ModelContext
    private var mockServerService: MockServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    
    override func setUp() {
        // initialize model context
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        self.mockServerService = MockServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        
        continueAfterFailure = false
        app.launch()
    }
}
