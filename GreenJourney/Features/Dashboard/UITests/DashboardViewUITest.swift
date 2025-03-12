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
        let co2Tracker = app.otherElements["co2Tracker"]
        let travelsRecap = app.otherElements["travelsRecap"]
        let worldExploration = app.otherElements["worldExploration"]
        
        // check elements present
        XCTAssertTrue(dashboardTitle.exists, "dashboardTitle is not displayed")
        XCTAssertTrue(co2Tracker.exists, "co2Tracker is not displayed")
        XCTAssertTrue(travelsRecap.exists, "travelsRecap is not displayed")
        XCTAssertTrue(worldExploration.exists, "worldExploration is not displayed")
    }
    
    func testCo2TrackerViewElements() {
        // UI elements
        let dashboardTitle = app.staticTexts["dashboardTitle"]
        let co2Tracker = app.otherElements["co2Tracker"]
        
        // check elements present
        XCTAssertTrue(dashboardTitle.exists, "dashboardTitle is not displayed")
        XCTAssertTrue(co2Tracker.exists, "co2Tracker is not displayed")
        
        // tap co2 tracker box
        co2Tracker.tap()
        
        // UI elements
        let co2CompenationRecap = app.otherElements["co2CompenationRecap"]
        let co2EmittedPerVehicle = app.otherElements["co2EmittedPerVehicle"]
        let co2EmittedPerYear = app.otherElements["co2EmittedPerYear"]
        let plantedTreesPerYear = app.otherElements["plantedTreesPerYear"]
        
        // check elements present
        XCTAssertTrue(co2CompenationRecap.waitForExistence(timeout: timer), "co2CompenationRecap is not displayed")
        XCTAssertTrue(co2EmittedPerVehicle.exists, "co2EmittedPerVehicle is not displayed")
        XCTAssertTrue(co2EmittedPerYear.exists, "co2EmittedPerYear is not displayed")
        XCTAssertTrue(plantedTreesPerYear.exists, "plantedTreesPerYear is not displayed")
    }
    
    func testTravelRecapViewElements() {
        // UI elements
        let dashboardTitle = app.staticTexts["dashboardTitle"]
        let travelsRecap = app.otherElements["travelsRecap"]
        
        // check elements present
        XCTAssertTrue(dashboardTitle.exists, "dashboardTitle is not displayed")
        XCTAssertTrue(travelsRecap.exists, "co2Tracker is not displayed")
        
        // tap co2 tracker box
        travelsRecap.tap()
        
        // UI elements
        let distancePerVehicle = app.otherElements["distancePerVehicle"]
        let distancePerYear = app.otherElements["distancePerYear"]
        let mostChosenVehicle = app.otherElements["mostChosenVehicle"]
        let tripsCompleted = app.otherElements["tripsCompleted"]
        let distanceTimeRecap = app.otherElements["distanceTimeRecap"]
        
        // check elements present
        XCTAssertTrue(distancePerVehicle.waitForExistence(timeout: timer), "distancePerVehicle is not displayed")
        XCTAssertTrue(distancePerYear.exists, "distancePerYear is not displayed")
        XCTAssertTrue(mostChosenVehicle.exists, "mostChosenVehicle is not displayed")
        XCTAssertTrue(tripsCompleted.exists, "tripsCompleted is not displayed")
        XCTAssertTrue(distanceTimeRecap.exists, "distanceTimeRecap is not displayed")
    }
    
    func testWorldExplorationViewElements() {
        // UI elements
        let dashboardTitle = app.staticTexts["dashboardTitle"]
        let worldExploration = app.otherElements["worldExploration"]
        
        // check elements present
        XCTAssertTrue(dashboardTitle.exists, "dashboardTitle is not displayed")
        XCTAssertTrue(worldExploration.exists, "co2Tracker is not displayed")
        
        // tap co2 tracker box
        worldExploration.tap()
        
        // UI elements
        let visitedContinents = app.otherElements["visitedContinents"]
        let countriesPerContinent = app.otherElements["countriesPerContinent"]
        let visitedCountries = app.otherElements["visitedCountries"]
        
        // check elements present
        XCTAssertTrue(visitedContinents.waitForExistence(timeout: timer), "visitedContinents is not displayed")
        XCTAssertTrue(countriesPerContinent.exists, "countriesPerContinent is not displayed")
        XCTAssertTrue(visitedCountries.exists, "visitedCountries is not displayed")
    }
}
