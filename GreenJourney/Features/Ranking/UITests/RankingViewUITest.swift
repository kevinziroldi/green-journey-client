import XCTest

final class RankingViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
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
        let rankingTabButton = app.tabBars.buttons["rankingTabViewElement"]
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
        
        // tap tab button
        rankingTabButton.tap()
        
        // check MyTravels page
        XCTAssertTrue(rankingTitle.waitForExistence(timeout: timer), "RankingView not appeared after selecting it")
    }
    
    func testRankingViewElementsExist() {
        // UI elements
        let rankingTitle = app.staticTexts["rankingTitle"]
        let userPreferencesButton = app.buttons["userPreferencesButton"]
        let distanceControl = app.segmentedControls["shortLongDistanceControl"]
        let errorMessage = app.staticTexts["errorMessage"]
        let leaderboard = app.otherElements["leaderboard"]
        let leaderBoardUserLongDistance = app.otherElements["leaderboardUserLongDistance"]
        let leaderboardUserShortDistance = app.otherElements["leaderboardUserShortDistance"]
        
        // check elements exist
        XCTAssertTrue(rankingTitle.waitForExistence(timeout: timer), "The rankingTitle is not displayed")
        XCTAssertTrue(userPreferencesButton.exists, "The userPreferencesButton is not displayed")
        XCTAssertTrue(distanceControl.exists, "The distanceControl is not displayed")
        XCTAssertFalse(errorMessage.exists, "The errorMessage is displayed")
        XCTAssertTrue(leaderboard.exists, "The leaderboard is not displayed")
        XCTAssertTrue(leaderBoardUserLongDistance.exists, "The leaderBoardUserLongDistance is not displayed")
        XCTAssertFalse(leaderboardUserShortDistance.exists, "The leaderboardUserShortDistance is displayed")
    }
    
    func testNavigatioToUserPreferences() {
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
    
    func testDistanceControlTap() {
        // UI elements
        let rankingTitle = app.staticTexts["rankingTitle"]
        let distanceControl = app.segmentedControls["shortLongDistanceControl"]
        let errorMessage = app.staticTexts["errorMessage"]
        
        // check elements exist
        XCTAssertTrue(rankingTitle.waitForExistence(timeout: timer), "The rankingTitle is not displayed")
        XCTAssertTrue(distanceControl.exists, "The distanceControl is not displayed")
        XCTAssertFalse(errorMessage.exists, "The errorMessage is displayed")
        
        // tap control distance button
        distanceControl.tap()
        
        // check elements exist (and right page)
        XCTAssertTrue(rankingTitle.waitForExistence(timeout: timer), "The rankingTitle is not displayed")
        XCTAssertTrue(distanceControl.exists, "The distanceControl is not displayed")
        XCTAssertFalse(errorMessage.exists, "The errorMessage is displayed")
    }
}
