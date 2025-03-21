import XCTest

final class RankingLeaderBoardViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    let deviceSize = UITestsDeviceSize.deviceSize
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        navigateToRankingLeaderBoardView()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToRankingLeaderBoardView() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        
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
        
        // UI elements
        let rankingTitle = app.staticTexts["rankingTitle"]
        let longDistanceNavigationView = app.otherElements["longDistanceNavigationView"]
        
        // check ranking page
        XCTAssertTrue(rankingTitle.waitForExistence(timeout: timer), "RankingView not appeared after selecting it")
        XCTAssertTrue(longDistanceNavigationView.exists, "longDistanceNavigationView not displayed")
        
        // tap long distance ranking button
        longDistanceNavigationView.tap()
        
        // UI elements
        let rankingName = app.staticTexts["rankingName"]
        
        // check correct View
        XCTAssertTrue(rankingName.waitForExistence(timeout: timer), "rankingName not displayed")
    }
    
    func testRankingLeaderBoardUIElementsPresent() {
        // UI elements
        let rankingName = app.staticTexts["rankingName"]
        let errorMessage = app.staticTexts["errorMessage"]
        let leaderboard = app.otherElements["leaderboard"]
        let leaderboardUser = app.otherElements["leaderboardUser"]
        let tableHeader = app.otherElements["tableHeader"]
        let firstRankingRow = app.buttons["rankingRow_0"]
        let lastRankingRow = app.buttons["rankingRow_9"]
        
        // check elements
        XCTAssertTrue(rankingName.waitForExistence(timeout: timer), "rankingName not displayed")
        XCTAssertFalse(errorMessage.exists, "errorMessage displayed")
        XCTAssertTrue(leaderboard.exists, "leaderboard not displayed")
        XCTAssertTrue(leaderboardUser.exists, "leaderboardUser not displayed")
        XCTAssertTrue(tableHeader.exists, "The table header is not displayed")
        XCTAssertTrue(firstRankingRow.exists, "The first row is not displayed")
        XCTAssertTrue(lastRankingRow.exists, "The last row is not displayed")
    }
    
    func testNavigationUserDetailsRanking() {
        // UI elements
        let leaderboard = app.otherElements["leaderboard"]
        let tableHeader = app.otherElements["tableHeader"]
        let firstRankingRow = app.buttons["rankingRow_0"]
        
        // check for existnce of UI elements
        XCTAssertTrue(leaderboard.exists, "The leaderboard is not displayed")
        XCTAssertTrue(tableHeader.exists, "The table header is not displayed")
        XCTAssertTrue(firstRankingRow.exists, "The first row is not displayed")
        
        // tap on first row
        firstRankingRow.tap()
        
        // check page changes
        let userDetailsTitle = app.staticTexts["userDetailsTitle"]
        XCTAssertTrue(userDetailsTitle.waitForExistence(timeout: timer), "The user details ranking view was not displayed")
    }
}
