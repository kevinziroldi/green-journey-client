import XCTest

final class OutwardOptionsViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    let deviceSize = UITestsDeviceSize.deviceSize
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        navigateToOutwardOptions()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToOutwardOptions() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        
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
        
        // UI elements TravelSearch
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let departureButton = app.buttons["departureButton"]
        let destinationButton = app.buttons["destinationButton"]
        let searchedCityTextField = app.textFields["searchedCityTextField"]
        let listElementMilano = app.otherElements["listElement_MIL_IT"]
        let listElementRoma = app.otherElements["listElement_ROM_IT"]
        let searchButton = app.buttons["searchButton"]
        
        XCTAssertTrue(travelSearchViewTitle.exists, "travelSearchViewTitle not displayed")
        
        // check departure button
        XCTAssertTrue(departureButton.exists, "departureButton not appeared after login")
        // tap departure button
        departureButton.tap()
        // check completer displayed
        XCTAssertTrue(searchedCityTextField.waitForExistence(timeout: timer), "completer view not displayed")
        // check element Milano
        XCTAssertTrue(listElementMilano.exists, "listElementMilano is not displayed")
        // tap button
        listElementMilano.tap()
        
        // tap destination button
        destinationButton.tap()
        // check completer displayed
        XCTAssertTrue(searchedCityTextField.waitForExistence(timeout: timer), "completer view not displayed")
        // type text
        searchedCityTextField.typeText("R")
        // check Roma displayed
        XCTAssertTrue(listElementRoma.exists, "listElementRoma is not displayed")
        // tap Roma
        listElementRoma.tap()
        
        XCTAssertTrue(travelSearchViewTitle.exists, "travelSearchViewTitle not displayed")
        
        searchButton.tap()
    }
    
    func testOutwardOptionsViewElementsExist() {
        // UI elements
        let fromTravelHeader = app.staticTexts["fromTravelHeader"]
        let fromToLine = app.otherElements["fromToLine"]
        let toTravelHeader = app.staticTexts["toTravelHeader"]
        let departureDate = app.staticTexts["departureDate"]
        let outwardOption_0 = app.buttons["outwardOption_0"]
        
        // check elements present
        XCTAssertTrue(fromTravelHeader.exists, "fromTravelHeader not displayed")
        if deviceSize == .regular {
            XCTAssertTrue(fromToLine.exists, "fromToLine not displayed")
        }
        XCTAssertTrue(toTravelHeader.exists, "toTravelHeader not displayed")
        XCTAssertTrue(departureDate.exists, "departureDate not displayed")
        XCTAssertTrue(outwardOption_0.exists, "outwardOption_0 not displayed")
    }
    
    func testOutwardOptionsFirstAndLast() {
        // UI elements
        let outwardOption_0 = app.buttons["outwardOption_0"]
        let outwardOption_6 = app.buttons["outwardOption_6"]
        
        // check first option present
        XCTAssertTrue(outwardOption_0.exists, "outwardOption_0 not displayed")
        
        app.swipeUp()
        app.swipeUp()
        
        // check last option present
        XCTAssertTrue(outwardOption_6.exists, "outwardOption_6 not displayed")
    }
    
    func testTapOutwardOpton() {
        // UI elements
        let outwardOption_0 = app.buttons["outwardOption_0"]
        
        XCTAssertTrue(outwardOption_0.exists, "outwardOption_0 not displayed")
        
        // tap option
        outwardOption_0.tap()
        
        // UI elements OptionDetails
        let saveTravelButton = app.buttons["saveTravelButtonOneWay"]
        
        XCTAssertTrue(saveTravelButton.exists, "saveTravelButton not displayed")
        
        saveTravelButton.tap()
        
        // check TravelSearch page
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearch page not displayed after saving travel")
    }
}
