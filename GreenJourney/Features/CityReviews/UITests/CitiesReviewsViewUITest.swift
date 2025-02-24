import XCTest

final class CitiesReviewsViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
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
        
        let citiesReviewsTabButton = app.tabBars.buttons["citiesReviewsTabViewElement"]
        
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
        
        // tap tab button
        citiesReviewsTabButton.tap()
        
        // check MyTravels page
        XCTAssertTrue(citiesReviewsTitle.waitForExistence(timeout: timer), "CitiesReviewsVoiew not appeared after selecting it")
    }
    
    func testCitiesReviewsViewElementsPresent() {
        // UI elements
        let citiesReviewsTitle = app.staticTexts["citiesReviewsTitle"]
        let userPreferencesButton = app.buttons["userPreferencesButton"]
        let selectCityText = app.staticTexts["selectCityText"]
        let searchCityReviews = app.buttons["searchCityReviews"]
        let searchButton = app.buttons["searchButton"]
        let topCitiesTitle = app.staticTexts["topCitiesTitle"]
        let bestCity_0 = app.otherElements["bestCityView_0"]
        let bestCity_1 = app.otherElements["bestCityView_1"]
        let bestCity_2 = app.otherElements["bestCityView_2"]
     
        // check elements present
        XCTAssertTrue(citiesReviewsTitle.exists, "citiesReviewsTitle is not displayed")
        XCTAssertTrue(userPreferencesButton.exists, "userPreferencesButton is not displayed")
        XCTAssertTrue(selectCityText.exists, "selectCityText is not displayed")
        XCTAssertTrue(searchCityReviews.exists, "searchCityReviews is not displayed")
        XCTAssertTrue(searchButton.exists, "searchButton is not displayed")
        XCTAssertTrue(topCitiesTitle.exists, "topCitiesTitle is not displayed")
        XCTAssertTrue(bestCity_0.exists, "bestCity_0 is not displayed")
        XCTAssertTrue(bestCity_1.exists, "bestCity_1 is not displayed")
        XCTAssertTrue(bestCity_2.exists, "bestCity_2 is not displayed")
    }
    
    func testNavigationToUserPreferences() {
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
    
    func testNavigationToCitiesReviewsDetails() {
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
    
    func testCitySearch() {
        // UI elements
        let citiesReviewsTitle = app.staticTexts["citiesReviewsTitle"]
        let searchCityReviews = app.buttons["searchCityReviews"]
        let searchButton = app.buttons["searchButton"]
        
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
        
        XCTAssertTrue(searchButton.waitForExistence(timeout: timer), "searchButton is not displayed")
        
        // tap search button
        searchButton.tap()
        
        // new view
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selecteCityTitle is not displayed")        
    }
    
}
