import XCTest

final class RankingViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    let deviceSize = UITestsDeviceSize.deviceSize
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        navigateToRankingView()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToRankingView() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let rankingTitle = app.staticTexts["rankingTitle"]
        
        XCTAssertTrue(emailTextField.exists, "The email field is not displayed")
        XCTAssertTrue(passwordField.exists, "The password field is not displayed")
        XCTAssertTrue(loginButton.exists, "The login button is not displayed")
        
        // insert data
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        passwordField.tap()
        passwordField.typeText("test_password")
        // tap login button
        loginButton.tap()
        
        // check page change after login
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearchView not appeared after login")
        
        // tap button
        if deviceSize == .compact {
            let rankingTabButton = app.tabBars.buttons["rankingTabViewElement"]
            rankingTabButton.tap()
        } else {
            // .regular
            let app = XCUIApplication()
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.5))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5))
            start.press(forDuration: 0.1, thenDragTo: end)
            
            let citiesReviewsTabButton = app.otherElements["rankingTabViewElement"]
            XCTAssertTrue(citiesReviewsTabButton.exists)
            citiesReviewsTabButton.tap()
            
            let right = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
            right.tap()
        }
        
        // check ranking page
        XCTAssertTrue(rankingTitle.waitForExistence(timeout: timer), "RankingView not appeared after selecting it")
    }
    
    func testRankingViewElementsExist() {
        // UI elements
        let rankingTitle = app.staticTexts["rankingTitle"]
        let userPreferencesButton = app.buttons["userPreferencesButton"]
        let errorMessage = app.staticTexts["errorMessage"]
        
        let userBadgesView = app.otherElements["userBadgesView"]
        let userScoresView = app.otherElements["userScoresView"]
        
        let longDistanceNavigationView = app.otherElements["longDistanceNavigationView"]
        let shortDistanceNavigationView = app.otherElements["shortDistanceNavigationView"]
        
        // check elements exist
        XCTAssertTrue(rankingTitle.waitForExistence(timeout: timer), "The rankingTitle is not displayed")
        
        if deviceSize == .compact {
            XCTAssertTrue(userPreferencesButton.exists, "The userPreferencesButton is not displayed")
        }
        XCTAssertFalse(errorMessage.exists, "The errorMessage is displayed")
        
        XCTAssertTrue(userBadgesView.exists, "userBadgesView not displayed")
        XCTAssertTrue(userScoresView.exists, "userScoresView not displayed")
        
        XCTAssertTrue(longDistanceNavigationView.exists, "longDistanceNavigationView not displayed")
        XCTAssertTrue(shortDistanceNavigationView.exists, "shortDistanceNavigationView not displayed")
        
    }
    
    func testNavigatioToUserPreferences() throws {
        if deviceSize != .compact {
            throw XCTSkip("Compact devices only")
        }
        // UI elements
        let rankingTitle = app.staticTexts["rankingTitle"]
        let userPreferencesButton = app.buttons["userPreferencesButton"]
        
        // check elements exist
        XCTAssertTrue(rankingTitle.waitForExistence(timeout: timer), "The rankingTitle is not displayed")
        XCTAssertTrue(userPreferencesButton.exists, "The userPreferencesButton is not displayed")
        
        // tap user preference button
        userPreferencesButton.tap()
        
        // check change of view
        let userPreferencesTitle = app.staticTexts["userPreferencesTitle"]
        XCTAssertTrue(userPreferencesTitle.waitForExistence(timeout: timer), "The userPreferencesTitle is not displayed")
    }
    
    func testInfoBadges() {
        // UI elements
        let infoBadgesButton = app.buttons["infoBadgesButton"]
        let infoBadgesView = app.otherElements["infoBadgesView"]
        let infoBadgesCloseButton = app.buttons["infoBadgesCloseButton"]
        let infoBadgesContent = app.otherElements["infoBadgesContent"]
        
        // check elements displayed
        // info button present
        XCTAssertTrue(infoBadgesButton.exists, "infoBadgesButton not displayed")
        // modal closed
        XCTAssertFalse(infoBadgesView.exists, "infoBadgesView already displayed")
        XCTAssertFalse(infoBadgesContent.exists, "infoBadgesContent already displayed")
        XCTAssertFalse(infoBadgesCloseButton.exists, "infoBadgesCloseButton already displayed")
        
        // tap info button
        let infoBadgesButtonCenter = infoBadgesButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        infoBadgesButtonCenter.tap()
        
        // check elements displayed
        // modal open
        XCTAssertTrue(infoBadgesView.waitForExistence(timeout: timer), "infoBadgesView not displayed")
        XCTAssertTrue(infoBadgesContent.exists, "infoBadgesContent not displayed")
        XCTAssertTrue(infoBadgesCloseButton.exists, "infoBadgesCloseButton not displayed")
        
        // close info section
        let infoBadgesCloseButtonCenter = infoBadgesCloseButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        infoBadgesCloseButtonCenter.tap()
        
        // check elements displayed
        // modal close
        XCTAssertTrue(infoBadgesButton.exists, "infoBadgesButton not displayed")
        XCTAssertFalse(infoBadgesView.exists, "infoBadgesView already displayed")
        XCTAssertFalse(infoBadgesContent.exists, "infoBadgesContent already displayed")
        XCTAssertFalse(infoBadgesCloseButton.exists, "infoBadgesCloseButton already displayed")
    }
    
    func testInfoScores() {
        // UI elements
        let infoScoresButton = app.buttons["infoScoresButton"]
        let infoScoresView = app.otherElements["infoScoresView"]
        let infoScoresCloseButton = app.buttons["infoScoresCloseButton"]
        let infoScoresContent = app.otherElements["infoScoresContent"]
        
        // check elements displayed
        // info button present
        XCTAssertTrue(infoScoresButton.exists, "infoScoresButton not displayed")
        // modal closed
        XCTAssertFalse(infoScoresView.exists, "infoScoresView already displayed")
        XCTAssertFalse(infoScoresContent.exists, "infoScoresContent already displayed")
        XCTAssertFalse(infoScoresCloseButton.exists, "infoScoresCloseButton already displayed")
        
        // tap info button
        let infoScoresButtonCenter = infoScoresButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        infoScoresButtonCenter.tap()
        
        // check elements displayed
        // modal open
        XCTAssertTrue(infoScoresView.waitForExistence(timeout: timer), "infoScoresView not displayed")
        XCTAssertTrue(infoScoresContent.exists, "infoScoresContent not displayed")
        XCTAssertTrue(infoScoresCloseButton.exists, "infoScoresCloseButton not displayed")
        
        // close info section
        let infoScoresCloseButtonCenter = infoScoresCloseButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        infoScoresCloseButtonCenter.tap()
        
        // check elements displayed
        // modal close
        XCTAssertTrue(infoScoresButton.exists, "infoScoresButton not displayed")
        XCTAssertFalse(infoScoresView.exists, "infoScoresView already displayed")
        XCTAssertFalse(infoScoresContent.exists, "infoScoresContent already displayed")
        XCTAssertFalse(infoScoresCloseButton.exists, "infoScoresCloseButton already displayed")
    }
    
    func testNavigationLongDistanceRanking() {
        // UI elements
        let rankingTitle = app.staticTexts["rankingTitle"]
        let longDistanceNavigationView = app.otherElements["longDistanceNavigationView"]
        
        // check elements exist
        XCTAssertTrue(rankingTitle.exists, "Ranking page not displayed")
        XCTAssertTrue(longDistanceNavigationView.exists, "longDistanceNavigationView not displayed")
        
        // tap long distance ranking button
        longDistanceNavigationView.tap()
        
        // UI elements
        let rankingName = app.staticTexts["rankingName"]
        let errorMessage = app.staticTexts["errorMessage"]
        let leaderboard = app.otherElements["leaderboard"]
        let leaderboardUser = app.otherElements["leaderboardUser"]
        
        // check elements
        XCTAssertTrue(rankingName.waitForExistence(timeout: timer), "rankingName not displayed")
        XCTAssertFalse(errorMessage.exists, "errorMessage displayed")
        XCTAssertTrue(leaderboard.exists, "leaderboard not displayed")
        XCTAssertTrue(leaderboardUser.exists, "leaderboardUser not displayed")
    }
    
    func testNavigationShortDistanceRanking() {
        // UI elements
        let rankingTitle = app.staticTexts["rankingTitle"]
        let shortDistanceNavigationView = app.otherElements["shortDistanceNavigationView"]
        
        // swipe
        app.swipeUp()
        
        // check elements exist
        XCTAssertTrue(rankingTitle.exists, "Ranking page not displayed")
        XCTAssertTrue(shortDistanceNavigationView.exists, "longDistanceNavigationView not displayed")
        
        // tap long distance ranking button
        shortDistanceNavigationView.tap()
        
        // UI elements
        let rankingName = app.staticTexts["rankingName"]
        let errorMessage = app.staticTexts["errorMessage"]
        let leaderboard = app.otherElements["leaderboard"]
        let leaderboardUser = app.otherElements["leaderboardUser"]
        
        // check elements
        XCTAssertTrue(rankingName.waitForExistence(timeout: timer), "rankingName not displayed")
        XCTAssertFalse(errorMessage.exists, "errorMessage displayed")
        XCTAssertTrue(leaderboard.exists, "leaderboard not displayed")
        XCTAssertFalse(leaderboardUser.exists, "leaderboardUser displayed")
    }
}
