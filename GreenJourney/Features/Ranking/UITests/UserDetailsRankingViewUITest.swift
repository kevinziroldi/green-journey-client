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
        let rankingTitle = app.staticTexts["rankingTitle"]
        let firstRankingRow = app.buttons["rankingRow_0"]
        let userDetailsTitle = app.staticTexts["userDetailsTitle"]
        
        // check login view elements
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
        
        // check travel search view
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearchView not appeared after login")
        
        // tap ranking tab button
        rankingTabButton.tap()
        
        // check ranking view page
        XCTAssertTrue(rankingTitle.waitForExistence(timeout: timer), "RankingView not appeared after selecting it")
        
        // check first row displayed
        XCTAssertTrue(firstRankingRow.exists, "The first row is not displayed")
        
        // tap on first row
        firstRankingRow.tap()
        
        // check user details ranking page
        XCTAssertTrue(userDetailsTitle.waitForExistence(timeout: timer), "The user details ranking view was not displayed")
    }
    
    func testUserDetailsRankingViewElementsPresent() {
        // UI elements
        let userDetailsTitle = app.staticTexts["userDetailsTitle"]
        let userName = app.staticTexts["userName"]
        let badgesInfoButton = app.buttons["badgesInfoButton"]
        let userBadges = app.otherElements["userBadges"]
        let userTravelsRecap = app.otherElements["userTravelsRecap"]
        
        // check UI elements present
        XCTAssertTrue(userDetailsTitle.exists, "userDetailsTitle not displayed")
        XCTAssertTrue(userName.exists, "userName not displayed")
        XCTAssertTrue(badgesInfoButton.exists, "badgesInfoButton not displayed")
        XCTAssertTrue(userBadges.exists, "userBadges not displayed")
        XCTAssertTrue(userTravelsRecap.exists, "userTravelsRecap not displayed")
    }
    
    func testTapBadgesInfoButton() {
        // UI elements UserDetailsRankingView
        let userDetailsTitle = app.staticTexts["userDetailsTitle"]
        let userName = app.staticTexts["userName"]
        let badgesInfoButton = app.buttons["badgesInfoButton"]
        let userBadges = app.otherElements["userBadges"]
        let userTravelsRecap = app.otherElements["userTravelsRecap"]
        
        // check UI elements present
        XCTAssertTrue(userDetailsTitle.exists, "userDetailsTitle not displayed")
        XCTAssertTrue(badgesInfoButton.exists, "badgesInfoButton not displayed")
        
        // tap info button
        badgesInfoButton.tap()
        
        // UI elements LegendBadgeView
        let badgeDistanceDescription = app.otherElements["badgeDistanceDescription"]
        let badgeEcologicalChoiceDescription = app.otherElements["badgeEcologicalChoiceDescription"]
        let badgeTravelsNumberDescription = app.otherElements["badgeTravelsNumberDescription"]
        let badgeCompensationDescription = app.otherElements["badgeCompensationDescription"]
        let closeBadgesInfoButton = app.buttons["closeBadgesInfoButton"]
        
        // check UI elements present
        XCTAssertTrue(badgeDistanceDescription.waitForExistence(timeout: timer), "badgeDistanceDescription not displayed")
        XCTAssertTrue(badgeEcologicalChoiceDescription.exists, "badgeEcologicalChoiceDescription not displayed")
        XCTAssertTrue(badgeTravelsNumberDescription.exists, "badgeTravelsNumberDescription not displayed")
        XCTAssertTrue(badgeCompensationDescription.exists, "badgeCompensationDescription not displayed")
        XCTAssertTrue(closeBadgesInfoButton.exists, "closeBadgesInfoButton not displayed")
        
        // tap close button
        closeBadgesInfoButton.tap()
        
        // check UI elements present
        XCTAssertTrue(userDetailsTitle.exists, "userDetailsTitle not displayed")
        XCTAssertTrue(userName.exists, "userName not displayed")
        XCTAssertTrue(badgesInfoButton.exists, "badgesInfoButton not displayed")
        XCTAssertTrue(userBadges.exists, "userBadges not displayed")
        XCTAssertTrue(userTravelsRecap.exists, "userTravelsRecap not displayed")
    }
}

