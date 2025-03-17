import XCTest

final class EmailVerificationViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        navigateToEmailVerificationView()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToEmailVerificationView() {
        // UI elements LoginView
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let moveToSignUpButton = app.buttons["moveToSignUpButton"]
        
        // check LoginView
        XCTAssertTrue(emailTextField.exists, "The email field is not displayed")
        XCTAssertTrue(passwordField.exists, "The password field is not displayed")
        XCTAssertTrue(loginButton.exists, "The login button is not displayed")
        XCTAssertTrue(moveToSignUpButton.exists, "The move to signup button is not displayed")
        
        // tap button
        moveToSignUpButton.tap()
        
        // UI element SignupView
        let emailField = app.textFields["emailTextField"]
        let passwordSecureField = app.secureTextFields["passwordSecureField"]
        let repeatPasswordSecureField = app.secureTextFields["repeatPasswordSecureField"]
        let firstName = app.textFields["firstName"]
        let lastName = app.textFields["lastName"]
        let createAccountButton = app.buttons["createAccountButton"]
        
        // check SignupView
        XCTAssertTrue(emailField.exists, "The email field is not displayed")
        XCTAssertTrue(passwordSecureField.exists, "The password field is not displayed")
        XCTAssertTrue(repeatPasswordSecureField.exists, "The repeat password field is not displayed")
        XCTAssertTrue(firstName.exists, "The first name field is not displayed")
        XCTAssertTrue(lastName.exists, "The last name field is not displayed")
        
        // insert all required data
        emailField.tap()
        emailField.typeText("test@example.com")
        passwordSecureField.tap()
        passwordSecureField.typeText("password_test")
        repeatPasswordSecureField.tap()
        repeatPasswordSecureField.typeText("password_test")
        firstName.tap()
        firstName.typeText("first name")
        
        app.swipeUp()
        
        lastName.tap()
        lastName.typeText("last name")
        
        // tap button
        createAccountButton.tap()
        
        // UI element EmailVerificationView
        let emailVerificationPage = app.staticTexts["emailVerificationTitle"]
        
        // check email verification page and error message
        XCTAssertTrue(emailVerificationPage.waitForExistence(timeout: timer), "The email verification page is not displayed")
    }
    
    func testEmailVerificationViewElementsPresent() {
        // UI elements
        let emailVerificationTitle = app.staticTexts["emailVerificationTitle"]
        let emailSentText = app.staticTexts["emailSentText"]
        let resendEmailButton = app.buttons["resendEmailButton"]
        let proceedButton = app.buttons["proceedButton"]
        let errorMessage = app.staticTexts["errorMessage"]
        
        // check UI elements
        XCTAssertTrue(emailVerificationTitle.exists, "emailVerificationTitle is not displayed")
        XCTAssertTrue(emailSentText.exists, "emailSentText is not displayed")
        XCTAssertTrue(resendEmailButton.exists, "resendEmailButton is not displayed")
        XCTAssertTrue(proceedButton.exists, "proceedButton is not displayed")
        
        XCTAssertFalse(errorMessage.exists, "errorMessage is displayed")
    }
    
    func testResendEmailButton() {
        // UI elements
        let emailVerificationTitle = app.staticTexts["emailVerificationTitle"]
        let emailSentText = app.staticTexts["emailSentText"]
        let resendEmailButton = app.buttons["resendEmailButton"]
        let proceedButton = app.buttons["proceedButton"]
        let errorMessage = app.staticTexts["errorMessage"]
        
        // check UI elements
        XCTAssertTrue(emailVerificationTitle.exists, "emailVerificationTitle is not displayed")
        XCTAssertTrue(emailSentText.exists, "emailSentText is not displayed")
        XCTAssertTrue(resendEmailButton.exists, "resendEmailButton is not displayed")
        XCTAssertTrue(proceedButton.exists, "proceedButton is not displayed")
        XCTAssertFalse(errorMessage.exists, "errorMessage is displayed")
        
        // tap resend email button
        resendEmailButton.tap()
        
        // check UI elements again
        XCTAssertTrue(emailVerificationTitle.exists, "emailVerificationTitle is not displayed")
        XCTAssertTrue(emailSentText.exists, "emailSentText is not displayed")
        XCTAssertTrue(resendEmailButton.exists, "resendEmailButton is not displayed")
        XCTAssertTrue(proceedButton.exists, "proceedButton is not displayed")
        XCTAssertFalse(errorMessage.exists, "errorMessage is displayed")
    }
    
    func testProceedButton() {
        // UI elements EmailVerificationView
        let emailVerificationTitle = app.staticTexts["emailVerificationTitle"]
        let emailSentText = app.staticTexts["emailSentText"]
        let resendEmailButton = app.buttons["resendEmailButton"]
        let proceedButton = app.buttons["proceedButton"]
        let errorMessage = app.staticTexts["errorMessage"]
        
        // check UI elements
        XCTAssertTrue(emailVerificationTitle.exists, "emailVerificationTitle is not displayed")
        XCTAssertTrue(emailSentText.exists, "emailSentText is not displayed")
        XCTAssertTrue(resendEmailButton.exists, "resendEmailButton is not displayed")
        XCTAssertTrue(proceedButton.exists, "proceedButton is not displayed")
        XCTAssertFalse(errorMessage.exists, "errorMessage is displayed")
        
        // tap proceed button
        proceedButton.tap()
        
        // UI elements TravelSearchView
        let travelSearchTitle = app.staticTexts["travelSearchViewTitle"]
        
        // check TravelSearchView
        XCTAssertTrue(travelSearchTitle.waitForExistence(timeout: timer), "travelSearchTitle is not displayed")
    }
}
