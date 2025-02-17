import XCTest

final class LoginViewUITests: XCTestCase {
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
    
    func testLoginViewElementsExist() {
        // UI elements
        let logoImage = app.images["loginLogoImage"]
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let resendEmailTextField = app.textFields["resendEmailLabel"]
        let resetPasswordButton = app.buttons["resetPasswordButton"]
        let errorMessageTextField = app.textFields["errorMessageLabel"]
        let loginButton = app.buttons["loginButton"]
        let googleButton = app.buttons["googleSignInButton"]
        let signUpButton = app.buttons["signUpButton"]
        
        // check UI are elements present
        XCTAssertTrue(logoImage.exists, "The logo image is not displayed")
        XCTAssertTrue(emailTextField.exists, "The email field is not displayed")
        XCTAssertTrue(passwordField.exists, "The password field is not displayed")
        XCTAssertFalse(resendEmailTextField.exists, "The resend email field is displayed and should not")
        XCTAssertTrue(resetPasswordButton.exists, "The reset password button is not displayed")
        XCTAssertFalse(errorMessageTextField.exists, "The resend email field is displayed and should not")
        XCTAssertTrue(loginButton.exists, "The login button is not displayed")
        XCTAssertTrue(googleButton.exists, "The google sign in button is not displayed")
        XCTAssertTrue(signUpButton.exists, "The signup button is not displayed")
    }
    
    // TODO doesn't work
    func testLoginFlow() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let mainViewTextField = app.textFields["nextJourneyTitle"]
        
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
        XCTAssertTrue(mainViewTextField.waitForExistence(timeout: timer), "TravelSearchView not appeared after login")
    }
    
    /*
    // Test della navigazione verso la view di registrazione (Sign up)
    func testSignUpNavigation() {
        // Premi il bottone Sign up
        let signUpButton = app.buttons["Sign up"]
        XCTAssertTrue(signUpButton.exists, "Il bottone Sign up non esiste")
        signUpButton.tap()
        
        // Verifica che la SignupView venga presentata.
        // Per esempio, se nella SignupView hai un titolo con accessibilityIdentifier "SignupViewTitle":
        let signupTitle = app.staticTexts["SignupViewTitle"]
        XCTAssertTrue(signupTitle.waitForExistence(timeout: 2), "La SignupView non è apparsa dopo aver premuto Sign up")
    }
    
    // Test del flusso di reset password
    func testResetPasswordFlow() {
        // Inserisci un'email per il reset
        let emailTextField = app.textFields["Email"]
        XCTAssertTrue(emailTextField.waitForExistence(timeout: 2), "Il campo email non è stato trovato")
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        
        // Premi il bottone Reset password
        let resetPasswordButton = app.buttons["Reset password"]
        XCTAssertTrue(resetPasswordButton.exists, "Il bottone Reset password non esiste")
        resetPasswordButton.tap()
        
        // Verifica che venga visualizzato un messaggio di conferma (ad es. "Reset email sent")
        // Assicurati di impostare un accessibilityIdentifier o testo esplicito in viewModel per il messaggio
        let resetMessage = app.staticTexts["Reset email sent"]
        XCTAssertTrue(resetMessage.waitForExistence(timeout: 5), "Il messaggio di reset non è stato visualizzato")
    }
     */
}
