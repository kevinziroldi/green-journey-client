import XCTest

final class UserDetailsRankingViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        navigateToUserDetailsRankingView()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToUserDetailsRankingView() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let rankingTabButton = app.tabBars.buttons["rankingTabViewElement"]
        
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
        let leaderboard = app.otherElements["leaderboard"]
        let tableHeader = app.otherElements["tableHeader"]
        let firstRankingRow = app.buttons["rankingRow_0"]
        
        // check for existnce of UI elements
        XCTAssertTrue(rankingName.waitForExistence(timeout: timer), "rankingName not displayed")
        XCTAssertTrue(leaderboard.exists, "The leaderboard is not displayed")
        XCTAssertTrue(tableHeader.exists, "The table header is not displayed")
        XCTAssertTrue(firstRankingRow.exists, "The first row is not displayed")
        
        // tap on first row
        firstRankingRow.tap()
        
        // check page changes
        let userDetailsTitle = app.staticTexts["userDetailsTitle"]
        XCTAssertTrue(userDetailsTitle.waitForExistence(timeout: timer), "The user details ranking view was not displayed")
    }
    
    func testUserDetailsRankingViewElementsPresent() {
        // UI elements
        let userDetailsTitle = app.staticTexts["userDetailsTitle"]
        let userName = app.staticTexts["userName"]
        let userBadges = app.otherElements["userBadges"]
        let scoresView = app.otherElements["scoresView"]
        let userTravelsRecap = app.otherElements["userTravelsRecap"]
        
        // check UI elements present
        XCTAssertTrue(userDetailsTitle.exists, "userDetailsTitle not displayed")
        XCTAssertTrue(userName.exists, "userName not displayed")
        XCTAssertTrue(userBadges.exists, "userBadges not displayed")
        XCTAssertTrue(scoresView.exists, "scoresView not displayed")
        XCTAssertTrue(userTravelsRecap.exists, "userTravelsRecap not displayed")
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
}
