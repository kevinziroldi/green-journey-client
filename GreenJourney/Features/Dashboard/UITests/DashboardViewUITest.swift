import XCTest

final class DashboardViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        moveToDashboardView()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func moveToDashboardView() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let dashboardTabViewElement = app.tabBars.buttons["dashboardTabViewElement"]
        let dashboardTitle = app.staticTexts["dashboardTitle"]
        
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
        dashboardTabViewElement.tap()
        
        // check dashboard page
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: timer), "DashboardView not appeared after selecting it")
    }
    
    func testDashBoardElementsPresent() {
        // UI elements
        let dashboardTitle = app.staticTexts["dashboardTitle"]
        let userBadges = app.otherElements["userBadges"]
        let co2Tracker = app.otherElements["co2Tracker"]
        let travelsRecap = app.otherElements["travelsRecap"]
        let travelTime = app.otherElements["travelTime"]
        let tripsCompleted = app.otherElements["tripsCompleted"]
        let distanceTraveled = app.otherElements["distanceTraveled"]
        
        // check elements present
        XCTAssertTrue(dashboardTitle.exists, "dashboardTitle is not displayed")
        XCTAssertTrue(userBadges.exists, "userBadges is not displayed")
        XCTAssertTrue(co2Tracker.exists, "co2Tracker is not displayed")
        XCTAssertTrue(travelsRecap.exists, "travelsRecap is not displayed")
        XCTAssertTrue(travelTime.exists, "travelTime is not displayed")
        XCTAssertTrue(tripsCompleted.exists, "tripsCompleted is not displayed")
        XCTAssertTrue(distanceTraveled.exists, "distanceTraveled is not displayed")
    }
}
