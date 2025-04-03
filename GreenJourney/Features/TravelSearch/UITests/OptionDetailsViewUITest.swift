import XCTest

final class OptionDetailsViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToOptionDetailsViewOneWay() {
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
        
        // UI elements
        let outwardOption_0 = app.buttons["outwardOption_0"]
        
        XCTAssertTrue(outwardOption_0.exists, "outwardOption_0 not displayed")
        
        // tap option
        outwardOption_0.tap()
    }
    
    private func navigateToOptionDetailsViewTwoWays() {
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
        let tripTypePicker = app.switches.firstMatch
        
        XCTAssertTrue(travelSearchViewTitle.exists, "travelSearchViewTitle not displayed")
        
        // check picker present
        XCTAssertTrue(tripTypePicker.exists, "tripTypePicker not displayed")
        
        // tap button
        tripTypePicker.tap()
        
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
        
        // UI elements
        let outwardOption_0 = app.buttons["outwardOption_0"]
        
        XCTAssertTrue(outwardOption_0.waitForExistence(timeout: timer), "outwardOption_0 not displayed")
        
        // tap option
        outwardOption_0.tap()
    }
    
    private func navigateToOptionDetailsViewWithInfo() {
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
        
        // UI elements
        let outwardOption_2 = app.buttons["outwardOption_3"]
        
        XCTAssertTrue(outwardOption_2.exists, "outwardOption_3 not displayed")
        
        // tap option
        outwardOption_2.tap()
    }
    
    func testOptionDetailsViewElementsPresent() {
        navigateToOptionDetailsViewOneWay()
        
        // UI elements
        let co2EmittedBox = app.otherElements["co2EmittedBox"]
        let travelRecap = app.otherElements["travelRecap"]
        let proceedButton = app.buttons["proceedButton"]
        let saveTravelButtonTwoWays = app.buttons["saveTravelButtonTwoWays"]
        let saveTravelButtonOneWay = app.buttons["saveTravelButtonOneWay"]
        
        XCTAssertTrue(co2EmittedBox.waitForExistence(timeout: timer), "co2EmittedBox")
        XCTAssertTrue(travelRecap.exists, "travelRecap not displayed")
        
        XCTAssertTrue(saveTravelButtonOneWay.exists, "saveTravelButtonOneWay not displayed")
        
        XCTAssertFalse(proceedButton.exists, "proceedButton displayed")
        XCTAssertFalse(saveTravelButtonTwoWays.exists, "saveTravelButtonTwoWays displayed")
    }
    
    func testSaveTravelOneWayTap() {
        navigateToOptionDetailsViewOneWay()
        
        // UI elements
        let saveTravelButtonOneWay = app.buttons["saveTravelButtonOneWay"]
        
        XCTAssertTrue(saveTravelButtonOneWay.exists, "saveTravelButtonOneWay not displayed")
        
        // tap button
        saveTravelButtonOneWay.tap()
        
        // check TravelSearch page
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearch page not displayed after saving travel")
    }
    
    func testSaveTravelTwoWays() {
        navigateToOptionDetailsViewTwoWays()
        
        // UI elements OptionDetails
        let proceedButton = app.buttons["proceedButton"]
        
        XCTAssertTrue(proceedButton.waitForExistence(timeout: timer), "proceedButton not displayed")
        
        // tap save button
        proceedButton.tap()
        
        // UI elements
        let returnOption_0 = app.buttons["returnOption_0"]
        
        XCTAssertTrue(returnOption_0.exists, "outwardOption_0 not displayed")
        
        // tap option
        returnOption_0.tap()
        
        // UI elements OptionDetails
        let saveTravelButton = app.buttons["saveTravelButtonTwoWays"]
        
        XCTAssertTrue(saveTravelButton.exists, "saveTravelButton not displayed")
        
        // tap save travel
        saveTravelButton.tap()
        
        // check TravelSearch page
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearch page not displayed after saving travel")
    }
    
    func testSegmentDetailsNoInfo() {
        navigateToOptionDetailsViewOneWay()
        
        // UI elements
        let segmentLine = app.otherElements["segmentLine"]
        let segmentDeparture = app.staticTexts["segmentDeparture"]
        let vehicleImage = app.otherElements["vehicleImage"]
        let openDetailsButton = app.buttons["openDetailsButton"]
        let detailsBox = app.otherElements["detailsBox"]
        let segmentDestination = app.staticTexts["segmentDestination"]
        let departureDate = app.staticTexts["departureDate"]
        let arrivalDate = app.staticTexts["arrivalDate"]
        let segmentInfo = app.otherElements["segmentInfo"]
        
        // check elements present before opening details
        XCTAssertTrue(segmentLine.exists, "segmentLine not displayed")
        XCTAssertTrue(segmentDeparture.exists, "segmentDeparture not displayed")
        XCTAssertTrue(vehicleImage.exists, "vehicleImage not displayed")
        XCTAssertTrue(openDetailsButton.exists, "openDetailsButton not displayed")
        XCTAssertTrue(segmentDestination.exists, "segmentDestination not displayed")
        XCTAssertTrue(departureDate.exists, "departureDate not displayed")
        XCTAssertTrue(arrivalDate.exists, "arrivalDate not displayed")
    
        XCTAssertFalse(detailsBox.exists, "detailsBox displayed")
        XCTAssertFalse(segmentInfo.exists, "segmentInfo displayed")
        
        // tap button to expand details
        openDetailsButton.tap()
        
        // check elements present before opening details
        XCTAssertTrue(segmentLine.exists, "segmentLine not displayed")
        XCTAssertTrue(segmentDeparture.exists, "segmentDeparture not displayed")
        XCTAssertTrue(vehicleImage.exists, "vehicleImage not displayed")
        XCTAssertTrue(openDetailsButton.exists, "openDetailsButton not displayed")
        XCTAssertTrue(segmentDestination.exists, "segmentDestination not displayed")
        XCTAssertTrue(departureDate.exists, "departureDate not displayed")
        XCTAssertTrue(arrivalDate.exists, "arrivalDate not displayed")
    
        XCTAssertTrue(detailsBox.exists, "detailsBox not displayed")
        XCTAssertFalse(segmentInfo.exists, "segmentInfo displayed")
    }
    
    func testSegmentDetailsWithInfo() {
        navigateToOptionDetailsViewWithInfo()
        
        // UI elements
        let segmentLine = app.otherElements["segmentLine"]
        let segmentDeparture = app.staticTexts["segmentDeparture"]
        let vehicleImage = app.otherElements["vehicleImage"]
        let openDetailsButton = app.buttons.matching(identifier: "openDetailsButton").element(boundBy: 0)
        let detailsBox = app.otherElements["detailsBox"]
        let segmentDestination = app.staticTexts["segmentDestination"]
        let departureDate = app.staticTexts["departureDate"]
        let arrivalDate = app.staticTexts["arrivalDate"]
        let segmentInfo = app.otherElements["segmentInfo"]
        
        // check elements present before opening details
        XCTAssertTrue(segmentLine.exists, "segmentLine not displayed")
        XCTAssertTrue(segmentDeparture.exists, "segmentDeparture not displayed")
        XCTAssertTrue(vehicleImage.exists, "vehicleImage not displayed")
        XCTAssertTrue(openDetailsButton.exists, "openDetailsButton not displayed")
        XCTAssertTrue(segmentDestination.exists, "segmentDestination not displayed")
        XCTAssertTrue(departureDate.exists, "departureDate not displayed")
        XCTAssertTrue(arrivalDate.exists, "arrivalDate not displayed")
    
        XCTAssertFalse(detailsBox.exists, "detailsBox displayed")
        XCTAssertFalse(segmentInfo.exists, "segmentInfo displayed")
        
        // tap button to expand details
        openDetailsButton.tap()
        
        // check elements present before opening details
        XCTAssertTrue(segmentLine.exists, "segmentLine not displayed")
        XCTAssertTrue(segmentDeparture.exists, "segmentDeparture not displayed")
        XCTAssertTrue(vehicleImage.exists, "vehicleImage not displayed")
        XCTAssertTrue(openDetailsButton.exists, "openDetailsButton not displayed")
        XCTAssertTrue(segmentDestination.exists, "segmentDestination not displayed")
        XCTAssertTrue(departureDate.exists, "departureDate not displayed")
        XCTAssertTrue(arrivalDate.exists, "arrivalDate not displayed")
    
        XCTAssertTrue(detailsBox.exists, "detailsBox not displayed")
        XCTAssertTrue(segmentInfo.exists, "segmentInfo not displayed")
    }
}

