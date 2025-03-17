import XCTest

final class TravelSearchViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    let deviceSize = UITestsDeviceSize.deviceSize
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        // execute login, move to TravelSearchView
        navigateToTravelSearchView()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToTravelSearchView() {
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
    }
    
    func testTravelSearchViewElementsPresent() {
        // UI elements
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let userPreferencesButton = app.buttons["userPreferencesButton"]
        let tripTypePicker = app.segmentedControls["tripTypePicker"]
        let departureLabel = app.staticTexts["departureLabel"]
        let departureButton = app.buttons["departureButton"]
        let destinationLabel = app.staticTexts["destinationLabel"]
        let destinationButton = app.buttons["destinationButton"]
        let outwardDateButton = app.buttons["outwardDateButton"]
        let returnDateButton = app.buttons["returnDateButton"]
        let searchButton = app.buttons["searchButton"]
        let getRecommendationButton = app.buttons["getRecommendationButton"]
        let dismissAIButton = app.buttons["dismissAIButton"]
        let newGenerationButton = app.buttons["newGenerationButton"]
        
        // check UI elements present
        XCTAssertTrue(travelSearchViewTitle.exists, "travelSearchViewTitle is not displayed")
        if deviceSize == .compact {
            XCTAssertTrue(userPreferencesButton.exists, "userPreferencesButton is not displayed")
        }
        XCTAssertTrue(tripTypePicker.exists, "tripTypePicker is not displayed")
        XCTAssertTrue(departureLabel.exists, "departureLabel is not displayed")
        XCTAssertTrue(departureButton.exists, "departureButton is not displayed")
        XCTAssertTrue(destinationLabel.exists, "destinationLabel is not displayed")
        XCTAssertTrue(destinationButton.exists, "destinationButton is not displayed")
        XCTAssertTrue(outwardDateButton.exists, "outwardDateButton is not displayed")
        XCTAssertTrue(returnDateButton.exists, "returnDateButton is not displayed")
        XCTAssertTrue(searchButton.exists, "searchButton is not displayed")
        
        XCTAssertTrue(getRecommendationButton.exists, "getRecommendationButton is not displayed")
        XCTAssertFalse(dismissAIButton.exists, "dismissAIButton is not displayed")
        XCTAssertFalse(newGenerationButton.exists, "newGenerationButton is not displayed")
    }
    
    func testNavigationToUserPreferences() throws {
        if deviceSize != .compact {
            throw XCTSkip("Small devices only")
        }
        // UI elements
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let userPreferencesButton = app.buttons["userPreferencesButton"]
        
        // check elements exist
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "The travelSearchViewTitle is not displayed")
        XCTAssertTrue(userPreferencesButton.exists, "The userPreferencesButton is not displayed")
        
        // tap user preference button
        userPreferencesButton.tap()
        
        // check change of view
        let userPreferencesTitle = app.staticTexts["userPreferencesTitle"]
        XCTAssertTrue(userPreferencesTitle.waitForExistence(timeout: timer), "The userPreferencesTitle is not displayed")
    }
    
    func testSwitchTravelDirection() {
        // UI elements
        let tripTypePicker = app.segmentedControls["tripTypePicker"]
    
        let oneWayOption = tripTypePicker.buttons["One way"]
        let roundTripOption = tripTypePicker.buttons["Round trip"]
        
        // check picker present
        XCTAssertTrue(tripTypePicker.exists, "tripTypePicker not displayed")
        
        // one way should be default
        XCTAssertTrue(oneWayOption.isSelected, "One way should be default")
               
        // tap button
        tripTypePicker.tap()
        
        XCTAssertTrue(roundTripOption.isSelected, "Round trip should be selected")
    }
    
    func testDatePickerPresentationAndDismissal() {
        // UI elements
        let outwardDateButton = app.buttons["outwardDateButton"]
        let datePickerTitle = app.staticTexts["datePickerTitle"]
        let datePickerDoneButton = app.buttons["datePickerDoneButton"]
        
        XCTAssertTrue(outwardDateButton.exists, "outwardDateButton is not displayed")
        
        // tap button
        outwardDateButton.tap()
        
        XCTAssertTrue(datePickerTitle.exists, "datePickerTitle non displayed")
        XCTAssertTrue(datePickerDoneButton.exists, "datePickerDoneButton non displayed")
       
        // tap done button
        datePickerDoneButton.tap()
        
        XCTAssertFalse(datePickerTitle.exists, "datePickerTitle is displayed")
        XCTAssertFalse(datePickerDoneButton.exists, "datePickerDoneButton is displayed")
    }
    
    func testTravelSearch() {
        // UI elements
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
    
    // AI button tested in DestinationPredictionViewUITest
}
