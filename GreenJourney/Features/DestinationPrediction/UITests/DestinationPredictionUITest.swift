import XCTest

final class DestinationPredictionUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        navigateToTravelSearchView()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToTravelSearchView() {
        // UI elements LoginView
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        
        // check LoginView UI elements
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
        
        // UI element TravelSearchView
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let getRecommendationButton = app.buttons["getRecommendationButton"]
        
        // check page change after login
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearchView not appeared after login")
        XCTAssertTrue(getRecommendationButton.waitForExistence(timeout: timer), "getRecommendationButton not displayed")
    }
    
    func testTapGetRecommendationButton() {
        // UI elements
        let getRecommendationButton = app.buttons["getRecommendationButton"]
        
        // check button present
        XCTAssertTrue(getRecommendationButton.exists, "getRecommendationButton not displayed")
        
        // tap button
        getRecommendationButton.tap()
        
        // check button not present
        XCTAssertFalse(getRecommendationButton.exists, "getRecommendationButton is still displayed")
    }
}
