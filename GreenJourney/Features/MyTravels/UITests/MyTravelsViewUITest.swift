import XCTest

final class MyTravelsUITests: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    let deviceSize = UITestsDeviceSize.deviceSize
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
        
        navigateToMyTravelsView()
    }
    
    private func navigateToMyTravelsView() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let myTravelsTitle = app.staticTexts["myTravelsTitle"]
        
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
        if deviceSize == .small {
            let myTravelsTabButton = app.tabBars.buttons["myTravelsTabViewElement"]
            myTravelsTabButton.tap()
        } else {
            // .regular
            let app = XCUIApplication()
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.5))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5))
            start.press(forDuration: 0.1, thenDragTo: end)
            
            let citiesReviewsTabButton = app.otherElements["myTravelsTabViewElement"]
            XCTAssertTrue(citiesReviewsTabButton.exists)
            citiesReviewsTabButton.tap()
            
            let right = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
            right.tap()
        }
        
        // check MyTravels page
        XCTAssertTrue(myTravelsTitle.waitForExistence(timeout: timer), "MyTravelsView not appeared after selecting it")
    }
    
    func testMyTravelsViewElementsExist() {
        let myTravelsTitle = app.staticTexts["myTravelsTitle"]
        let userPreferencesButton = app.buttons["userPreferencesButton"]
        let travelCompletedControl = app.segmentedControls["travelCompletedControl"]
        let sortByButton = app.buttons["sortByButton"]
        
        XCTAssertTrue(myTravelsTitle.exists, "The title of the page is not present")
        
        if deviceSize == .small {
            XCTAssertTrue(userPreferencesButton.exists, "The button to access user preferences is not present")
        }
        
        XCTAssertTrue(travelCompletedControl.exists, "The travel completed picket is not present")
        XCTAssertTrue(sortByButton.exists, "The sort by button is not present")
    }
    
    func testNavigationToUserPreferences() throws {
        if deviceSize != .small {
            throw XCTSkip("Small device only")
        }
        // UI elements
        let myTravelsTitle = app.staticTexts["myTravelsTitle"]
        let userPreferencesButton = app.buttons["userPreferencesButton"]
        
        // check elements exist
        XCTAssertTrue(myTravelsTitle.waitForExistence(timeout: timer), "The rankingTitle is not displayed")
        XCTAssertTrue(userPreferencesButton.exists, "The userPreferencesButton is not displayed")
        
        // tap user preference button
        userPreferencesButton.tap()
        
        // check change of view
        let userPreferencesTitle = app.staticTexts["userPreferencesTitle"]
        XCTAssertTrue(userPreferencesTitle.waitForExistence(timeout: timer), "The userPreferencesTitle is not displayed")
    }
    
    func testSortByButtonShowsActionSheetTapCancelButton() {
        // UI elements
        let myTravelsTitle = app.staticTexts["myTravelsTitle"]
        let sortByButton = app.buttons["sortByButton"]
        let departureDateButton = app.sheets.buttons["Departure date"]
        let co2EmittedButton = app.sheets.buttons["CO2 emitted"]
        let co2CompensationRate = app.sheets.buttons["Departure date"]
        let priceButton = app.sheets.buttons["Price"]
        let cancelButton = app.sheets.buttons["Cancel"]
        
        // check sort by button exists
        XCTAssertTrue(sortByButton.exists, "The sort by button is not present")
        
        // tap button
        sortByButton.tap()
        
        // check all sort buttons are present
        XCTAssertTrue(departureDateButton.waitForExistence(timeout: timer), "Departure date button not found")
        XCTAssertTrue(co2EmittedButton.waitForExistence(timeout: timer), "Co2 emitted button not found")
        XCTAssertTrue(co2CompensationRate.waitForExistence(timeout: timer), "Co2 compensation rate button not found")
        XCTAssertTrue(priceButton.waitForExistence(timeout: timer), "Price button not found")
        XCTAssertTrue(cancelButton.waitForExistence(timeout: timer), "Cancel button not found")
        
        // close action sheet using cancel button
        cancelButton.tap()
        
        // check no button present
        XCTAssertFalse(departureDateButton.waitForExistence(timeout: timer), "Departure date button found")
        XCTAssertFalse(co2EmittedButton.waitForExistence(timeout: timer), "Co2 emitted button found")
        XCTAssertFalse(co2CompensationRate.waitForExistence(timeout: timer), "Co2 compensation rate button found")
        XCTAssertFalse(priceButton.waitForExistence(timeout: timer), "Price button found")
        XCTAssertFalse(cancelButton.waitForExistence(timeout: timer), "Cancel button found")
        // check title present
        XCTAssertTrue(myTravelsTitle.exists, "The title of the page is not present")
    }
     
    func testSortByButtonShowsActionSheetTapSortButton() {
        // UI elements
        let myTravelsTitle = app.staticTexts["myTravelsTitle"]
        let sortByButton = app.buttons["sortByButton"]
        let departureDateButton = app.sheets.buttons["Departure date"]
        let co2EmittedButton = app.sheets.buttons["CO2 emitted"]
        let co2CompensationRate = app.sheets.buttons["Departure date"]
        let priceButton = app.sheets.buttons["Price"]
        let cancelButton = app.sheets.buttons["Cancel"]
        
        // check sort by button exists
        XCTAssertTrue(sortByButton.exists, "The sort by button is not present")
        
        // tap button
        sortByButton.tap()
        
        // check all sort buttons are present
        XCTAssertTrue(departureDateButton.waitForExistence(timeout: timer), "Departure date button not found")
        XCTAssertTrue(co2EmittedButton.waitForExistence(timeout: timer), "Co2 emitted button not found")
        XCTAssertTrue(co2CompensationRate.waitForExistence(timeout: timer), "Co2 compensation rate button not found")
        XCTAssertTrue(priceButton.waitForExistence(timeout: timer), "Price button not found")
        XCTAssertTrue(cancelButton.waitForExistence(timeout: timer), "Cancel button not found")
        
        // choose a sorting method and tap the button
        departureDateButton.tap()
        
        // check no button present
        XCTAssertFalse(departureDateButton.waitForExistence(timeout: timer), "Departure date button found")
        XCTAssertFalse(co2EmittedButton.waitForExistence(timeout: timer), "Co2 emitted button found")
        XCTAssertFalse(co2CompensationRate.waitForExistence(timeout: timer), "Co2 compensation rate button found")
        XCTAssertFalse(priceButton.waitForExistence(timeout: timer), "Price button found")
        XCTAssertFalse(cancelButton.waitForExistence(timeout: timer), "Cancel button found")
        // check title present
        XCTAssertTrue(myTravelsTitle.exists, "The title of the page is not present")
    }
    
    func testTravelCardNavigationTap() {
        // UI elements
        let travelCardButton = app.buttons.matching(identifier: "travelCardButton_107").firstMatch
        let confirmTravelButton = app.buttons.matching(identifier: "confirmTravelButton_107").firstMatch
        let deleteTravelButton = app.buttons.matching(identifier: "deleteTravelButton_107").firstMatch
        
        // check travel card present
        XCTAssertTrue(travelCardButton.waitForExistence(timeout: timer), "The travel card was not found")
        XCTAssertTrue(confirmTravelButton.exists, "The confirm button was not found")
        XCTAssertTrue(deleteTravelButton.exists, "The delete button was not found")
        
        // tap travel card
        travelCardButton.tap()
        
        // check travel details view 
        let headerView = app.otherElements["headerView"]
        XCTAssertTrue(headerView.waitForExistence(timeout: timer), "The travel details view was not displayed")
    }
}
