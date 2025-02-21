import XCTest

final class CompleterViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        navigateToCompeleter()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToCompeleter() {
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
        
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let departureButton = app.buttons["departureButton"]
        
        // check page change after login
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearchView not appeared after login")
        XCTAssertTrue(departureButton.exists, "departureButton not appeared after login")
        
        // tap departure button
        departureButton.tap()
        
        let searchedCityTextField = app.textFields["searchedCityTextField"]
        
        // check completer displayed
        XCTAssertTrue(searchedCityTextField.waitForExistence(timeout: timer), "completer view not displayed")
    }
    
    func testCompleterViewElementsPresent() {
        // UI elements
        let backButtonTop = app.buttons["backButtonTop"]
        let searchedCityTextField = app.textFields["searchedCityTextField"]
        let listElementMilano = app.otherElements["listElement_MIL_IT"]
        let backButtonBottom = app.buttons["backButtonBottom"]
        
        // check existence
        XCTAssertTrue(backButtonTop.exists, "backButtonTop is not displayed")
        XCTAssertTrue(searchedCityTextField.exists, "searchedCityTextField is not displayed")
        XCTAssertTrue(listElementMilano.exists, "listElementMilano is not displayed")
        XCTAssertTrue(backButtonBottom.exists, "backButtonBottom is not displayed")
    }
    
    func testTapBackButtonTop() {
        // UI elements
        let backButtonTop = app.buttons["backButtonTop"]
        
        // check existence
        XCTAssertTrue(backButtonTop.exists, "backButtonTop is not displayed")
        
        // tap button
        backButtonTop.tap()
        
        // UI elements
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let departureButton = app.buttons["departureButton"]
        
        // check TravelSearchView displayed
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearchView not appeared")
        XCTAssertTrue(departureButton.exists, "departureButton not appeared")
    }
    
    func testBackButtonBottom() {
        // UI elements
        let backButtonBottom = app.buttons["backButtonBottom"]
        
        // check existence
        XCTAssertTrue(backButtonBottom.exists, "backButtonBottom is not displayed")
        
        // tap button
        backButtonBottom.tap()
        
        // UI elements
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let departureButton = app.buttons["departureButton"]
        
        // check TravelSearchView displayed
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearchView not appeared")
        XCTAssertTrue(departureButton.exists, "departureButton not appeared")
    }
    
    func testTapListElement() {
        // UI elements
        let listElementMilano = app.otherElements["listElement_MIL_IT"]
        
        // check existence
        XCTAssertTrue(listElementMilano.exists, "listElementMilano is not displayed")
        
        // tap button
        listElementMilano.tap()
        
        // UI elements
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let departureButton = app.buttons["departureButton"]
        
        // check TravelSearchView displayed
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearchView not appeared")
        XCTAssertTrue(departureButton.exists, "departureButton not appeared")
    }
    
    func testWriteAndTap() {
        // UI elements
        let searchedCityTextField = app.textFields["searchedCityTextField"]
        let listElementRoma = app.otherElements["listElement_ROM_IT"]
        
        // check existence
        XCTAssertTrue(searchedCityTextField.exists, "searchedCityTextField is not displayed")
        
        // type text
        searchedCityTextField.typeText("R")
        
        // check Roma displayed
        XCTAssertTrue(listElementRoma.exists, "listElementRoma is not displayed")
        
        // tap Roma
        listElementRoma.tap()
        
        // UI elements
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let departureButton = app.buttons["departureButton"]
        
        // check TravelSearchView displayed
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearchView not appeared")
        XCTAssertTrue(departureButton.exists, "departureButton not appeared")
    }
}
