import XCTest

final class LoginViewUITests: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func testLoginViewElementsExist() {
        // UI elements
        let loginLogoImage = app.images["loginLogoImage"]
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let resendEmailTextField = app.textFields["resendEmailLabel"]
        let resetPasswordButton = app.buttons["resetPasswordButton"]
        let errorMessageTextField = app.textFields["errorMessageLabelLogin"]
        let loginButton = app.buttons["loginButton"]
        let googleButton = app.buttons["googleSignInButton"]
        let signUpButton = app.buttons["moveToSignUpButton"]
        
        // check UI are elements present
        XCTAssertTrue(loginLogoImage.exists, "The logo image is not displayed")
        XCTAssertTrue(emailTextField.exists, "The email field is not displayed")
        XCTAssertTrue(passwordField.exists, "The password field is not displayed")
        XCTAssertFalse(resendEmailTextField.exists, "The resend email field is displayed and should not")
        XCTAssertTrue(resetPasswordButton.exists, "The reset password button is not displayed")
        XCTAssertFalse(errorMessageTextField.exists, "The resend email field is displayed and should not")
        XCTAssertTrue(loginButton.exists, "The login button is not displayed")
        XCTAssertTrue(googleButton.exists, "The google sign in button is not displayed")
        XCTAssertTrue(signUpButton.exists, "The signup button is not displayed")
    }
    
    func testLoginWithCredentialsSuccessful() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        
        // check UI are elements present
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
    
    func testLoginWithCredentialsFailure() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let loginLogoImage = app.images["loginLogoImage"]
        let errorMessageTextField = app.staticTexts["errorMessageLabelLogin"]
        
        // check UI are elements present
        XCTAssertTrue(emailTextField.exists, "The email field is not displayed")
        XCTAssertTrue(passwordField.exists, "The password field is not displayed")
        XCTAssertTrue(loginButton.exists, "The login button is not displayed")
        
        // insert only email
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        // tap login button
        loginButton.tap()
        
        // check login page and error message
        XCTAssertTrue(loginLogoImage.exists, "The login logo image is not displayed")
        XCTAssertTrue(errorMessageTextField.waitForExistence(timeout: timer), "The error message was not displayed")
    }
    
    func testSignInWithGoogle() {
        // UI elements
        let googleButton = app.buttons["googleSignInButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        
        // check Google sign in button exists
        XCTAssertTrue(googleButton.exists, "The google sign in button is not displayed")
        
        googleButton.tap()
        
        // check page change after login
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearchView not appeared after sign in with Google")
    }
    
    func testSignUpNavigation() {
        // UI elements
        let signUpButton = app.buttons["moveToSignUpButton"]
        let signupTitle = app.staticTexts["signupTitle"]
        
        XCTAssertTrue(signUpButton.exists, "The signup button is not displayed")
        signUpButton.tap()
        
        XCTAssertTrue(signupTitle.waitForExistence(timeout: timer), "Signup view did not appear after clicking signup button")
    }
    
    func testResetPasswordWithEmail() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let resetPasswordButton = app.buttons["resetPasswordButton"]
        let resendEmailTextField = app.staticTexts["resendEmailLabel"]
        
        // check UI elements exist
        XCTAssertTrue(emailTextField.exists, "The email field is not displayed")
        XCTAssertTrue(resetPasswordButton.exists, "The reset password button is not displayed")
        
        // insert email and tap reset password
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        resetPasswordButton.tap()
        
        XCTAssertTrue(resendEmailTextField.waitForExistence(timeout: timer), "The sent email message has not been displayed")
    }
    
    func testResetPasswordWithoutEmail() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let resetPasswordButton = app.buttons["resetPasswordButton"]
        let errorMessageTextField = app.staticTexts["errorMessageLabelLogin"]
        
        // check UI elements exist
        XCTAssertTrue(emailTextField.exists, "The email field is not displayed")
        XCTAssertTrue(resetPasswordButton.exists, "The reset password button is not displayed")
        
        // don't insert an email
        resetPasswordButton.tap()
        
        XCTAssertTrue(errorMessageTextField.waitForExistence(timeout: timer), "The error message was not displayed")
    }
}
