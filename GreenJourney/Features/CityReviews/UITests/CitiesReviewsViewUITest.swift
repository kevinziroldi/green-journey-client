import XCTest

final class CitiesReviewsViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    let deviceSize = UITestsDeviceSize.deviceSize
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        navigateToCitiesReviewsView()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToCitiesReviewsView() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        
        let citiesReviewsTitle = app.staticTexts["citiesReviewsTitle"]
        
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
        
        if deviceSize == .small {
            let citiesReviewsTabButton = app.tabBars.buttons["citiesReviewsTabViewElement"]
            citiesReviewsTabButton.tap()
        } else {
            // .regular
            let app = XCUIApplication()
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.5))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5))
            start.press(forDuration: 0.1, thenDragTo: end)
            
            let citiesReviewsTabButton = app.otherElements["citiesReviewsTabViewElement"]
            XCTAssertTrue(citiesReviewsTabButton.exists)
            citiesReviewsTabButton.tap()
            
            let right = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
            right.tap()
        }
        
        // check CitiesReviews page
        XCTAssertTrue(citiesReviewsTitle.waitForExistence(timeout: timer), "CitiesReviewsVoiew not appeared after selecting it")
    }
    
    func testCitiesReviewsViewElementsPresent() {
        // both small and regular devices
        
        // UI elements
        let citiesReviewsTitle = app.staticTexts["citiesReviewsTitle"]
        let userPreferencesButton = app.buttons["userPreferencesButton"]
        let selectCityText = app.staticTexts["selectCityText"]
        let searchCityReviews = app.buttons["searchCityReviews"]
        let reviewableCitiesTitle = app.staticTexts["reviewableCitiesTitle"]
        let reviewableCity_Berlin = app.otherElements["reviewableCityView_BER_DE"]
        let reviewableCity_Firenze = app.otherElements["reviewableCityView_FLR_IT"]
        let reviewableCity_Paris = app.otherElements["reviewableCityView_PAR_FR"]
        let reviewableCity_Roma = app.otherElements["reviewableCityView_ROM_IT"]
        let topCitiesTitle = app.staticTexts["topCitiesTitle"]
        let bestCity_0 = app.otherElements["bestCityView_0"]
        let bestCity_1 = app.otherElements["bestCityView_1"]
        let bestCity_2 = app.otherElements["bestCityView_2"]
        
        // check elements present
        XCTAssertTrue(citiesReviewsTitle.exists, "citiesReviewsTitle is not displayed")
        XCTAssertTrue(selectCityText.exists, "selectCityText is not displayed")
        
        if deviceSize == .small {
            XCTAssertTrue(userPreferencesButton.exists, "userPreferencesButton is not displayed")
        }
        
        XCTAssertTrue(searchCityReviews.exists, "searchCityReviews is not displayed")
        XCTAssertTrue(reviewableCitiesTitle.exists, "reviewableCitiesTitle is not displayed")
        XCTAssertTrue(reviewableCity_Berlin.exists, "reviewableCity_Berlin is not displayed")
        XCTAssertTrue(reviewableCity_Firenze.exists, "reviewableCity_Firenze is not displayed")
        
        reviewableCity_Berlin.swipeLeft()
        
        XCTAssertTrue(reviewableCity_Paris.waitForExistence(timeout: timer), "reviewableCity_Paris is not displayed")
        XCTAssertTrue(reviewableCity_Roma.exists, "reviewableCity_Roma is not displayed")
        XCTAssertTrue(topCitiesTitle.exists, "topCitiesTitle is not displayed")
        XCTAssertTrue(bestCity_0.exists, "bestCity_0 is not displayed")
        XCTAssertTrue(bestCity_1.exists, "bestCity_1 is not displayed")
        XCTAssertTrue(bestCity_2.exists, "bestCity_2 is not displayed")
    }
    
    func testNavigationToUserPreferences() {
        if deviceSize == .small {
            // UI elements
            let citiesReviewsTitle = app.staticTexts["citiesReviewsTitle"]
            let userPreferencesButton = app.buttons["userPreferencesButton"]
            
            // check elements exist
            XCTAssertTrue(citiesReviewsTitle.waitForExistence(timeout: timer), "The citiesReviewsTitle is not displayed")
            XCTAssertTrue(userPreferencesButton.exists, "The userPreferencesButton is not displayed")
            
            // tap user preference button
            userPreferencesButton.tap()
            
            // check change of view
            let userPreferencesTitle = app.staticTexts["userPreferencesTitle"]
            XCTAssertTrue(userPreferencesTitle.waitForExistence(timeout: timer), "The userPreferencesTitle is not displayed")
        }
    }
    
    func testCitySearch() {
        // both small and regular devices
        
        // UI elements
        let citiesReviewsTitle = app.staticTexts["citiesReviewsTitle"]
        let searchCityReviews = app.buttons["searchCityReviews"]
        
        XCTAssertTrue(citiesReviewsTitle.waitForExistence(timeout: timer), "The citiesReviewsTitle is not displayed")
        XCTAssertTrue(searchCityReviews.exists, "searchCityTextField is not displayed")
        
        // tap button
        searchCityReviews.tap()
        
        // UI elements completer
        let searchedCityTextField = app.textFields["searchedCityTextField"]
        let listElementMilano = app.otherElements["listElement_MIL_IT"]
        
        XCTAssertTrue(searchCityReviews.waitForExistence(timeout: timer), "searchCityTextField is not displayed")
        
        // search for Milano
        searchedCityTextField.typeText("M")
        
        XCTAssertTrue(listElementMilano.waitForExistence(timeout: timer), "listElementMilano is not displayed")

        // select Milano
        listElementMilano.tap()
        
        // new view
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selecteCityTitle is not displayed")
    }
    
    func testNavigationToCitiesReviewsDetailsReviewableCity() {
        // both small and regular devices
        
        // UI elements
        let citiesReviewsTitle = app.staticTexts["citiesReviewsTitle"]
        let reviewableCity_Berlin = app.otherElements["reviewableCityView_BER_DE"]
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        
        // check elements present
        XCTAssertTrue(citiesReviewsTitle.waitForExistence(timeout: timer), "The citiesReviewsTitle is not displayed")
        XCTAssertTrue(reviewableCity_Berlin.exists, "reviewableCity_Berlin is not displayed")
        
        // tap reviewableCity_Berlin button
        reviewableCity_Berlin.tap()
        
        // check new view
        XCTAssertTrue(selecteCityTitle.exists, "selecteCityTitle is not displayed")
    }
    
    func testNavigationToCitiesReviewsDetailsBestCity() {
        // both small and regular devices
        
        // UI elements
        let citiesReviewsTitle = app.staticTexts["citiesReviewsTitle"]
        let bestCity_0 = app.otherElements["bestCityView_0"]
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        
        // check elements present
        XCTAssertTrue(citiesReviewsTitle.waitForExistence(timeout: timer), "The citiesReviewsTitle is not displayed")
        XCTAssertTrue(bestCity_0.exists, "bestCity_0 is not displayed")
        
        // tap bestCity_0 button
        bestCity_0.tap()
        
        // check new view
        XCTAssertTrue(selecteCityTitle.exists, "selecteCityTitle is not displayed")
    }
}
