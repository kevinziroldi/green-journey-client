import XCTest

final class UserPreferencesViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        navigateToUserPreferences()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToUserPreferences() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let userPreferencesButton = app.buttons["userPreferencesButton"]
        
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
        
        // check page change after login
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearchView not appeared after login")
        XCTAssertTrue(userPreferencesButton.exists, "The userPreferencesButton is not displayed")
        
        // tap user preference button
        userPreferencesButton.tap()
        
        // check change of view
        let userPreferencesTitle = app.staticTexts["userPreferencesTitle"]
        XCTAssertTrue(userPreferencesTitle.waitForExistence(timeout: timer), "The userPreferencesTitle is not displayed")
    }
    
    func testUserPreferencesViewElementsExist() {
        // UI elements
        let userPreferencesTitle = app.staticTexts["userPreferencesTitle"]
        let greetingMessage = app.staticTexts["greetingMessage"]
        let completeProfileMessage = app.staticTexts["completeProfileMessage"]
        let editButton = app.buttons["editButton"]
        let cancelButton = app.buttons["cancelButton"]
        let saveButton = app.buttons["saveButton"]
        let firstNameTextField = app.textFields["firstNameTextField"]
        let lastNameTextField = app.textFields["lastNameTextField"]
        let datePicker = app.datePickers["birthDatePicker"]
        let genderPicker = app.descendants(matching: .any).matching(identifier: "genderPicker").firstMatch
        let cityTextField = app.textFields["cityTextField"]
        let streetNameTextField = app.textFields["streetNameTextField"]
        let houseNumberTextField = app.textFields["houseNumberTextField"]
        let zipCodeTextField = app.textFields["zipCodeTextField"]
        let email = app.staticTexts["email"]
        let modifyPasswordButton = app.buttons["modifyPasswordButton"]
        let emailSentMessage = app.staticTexts["emailSentMessage"]
        let errorMessage = app.staticTexts["errorMessage"]
        let logoutButton = app.buttons["logoutButton"]
 
        // check presence of UI elements
        XCTAssertTrue(editButton.exists, "editButton is not displayed")
        
        // tap edit button
        editButton.tap()
        
        XCTAssertTrue(userPreferencesTitle.exists, "userPreferencesTitle is not displayed")
        XCTAssertTrue(greetingMessage.exists, "greetingMessage is not displayed")
        XCTAssertTrue(completeProfileMessage.exists, "completeProfileMessage is not displayed")
        XCTAssertTrue(cancelButton.exists, "cancelButton is not displayed")
        XCTAssertTrue(saveButton.exists, "saveButton is not displayed")
        XCTAssertTrue(firstNameTextField.exists, "firstNameTextField is not displayed")
        XCTAssertTrue(lastNameTextField.exists, "lastNameTextField is not displayed")
        XCTAssertTrue(datePicker.exists, "datePicker is not displayed")
        XCTAssertTrue(genderPicker.exists, "genderPicker is not displayed")
        XCTAssertTrue(cityTextField.exists, "cityTextField is not displayed")
        XCTAssertTrue(streetNameTextField.exists, "streetNameTextField is not displayed")
        XCTAssertTrue(houseNumberTextField.exists, "houseNumberTextField is not displayed")
        XCTAssertTrue(zipCodeTextField.exists, "zipCodeTextField is not displayed")
        XCTAssertTrue(email.exists, "email is not displayed")
        XCTAssertTrue(modifyPasswordButton.exists, "modifyPasswordButton is not displayed")
        XCTAssertFalse(emailSentMessage.exists, "emailSentMessage is displayed")
        XCTAssertFalse(errorMessage.exists, "errorMessage is displayed")
        XCTAssertTrue(logoutButton.exists, "logoutButton is not displayed")
    }
    
    func testEditFieldAndCancel() {
        
    }
    
    func testEditFieldAndSave() {
        
    }
    
    func testModifyPassword() {
        
    }
    
    func testLogout() {
        
    }
}
