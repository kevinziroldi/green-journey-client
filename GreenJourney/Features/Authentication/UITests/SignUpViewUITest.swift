import XCTest

final class SignUpViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        moveTosignUp()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func moveTosignUp() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let moveToSignUpButton = app.buttons["moveToSignUpButton"]
        let signupTitle = app.staticTexts["signupTitle"]
        
        XCTAssertTrue(emailTextField.exists, "The email field is not displayed")
        XCTAssertTrue(passwordField.exists, "The password field is not displayed")
        XCTAssertTrue(loginButton.exists, "The login button is not displayed")
        XCTAssertTrue(moveToSignUpButton.exists, "The move to signup button is not displayed")
        
        moveToSignUpButton.tap()
        
        XCTAssertTrue(signupTitle.exists, "The signup page is not displayed")
    }
    
    func testSignUpElementsPresent() {
        // UI elements
        let signupTitle = app.staticTexts["signupTitle"]
        let emailField = app.textFields["emailTextField"]
        let passwordSecureField = app.secureTextFields["passwordSecureField"]
        let repeatPasswordSecureField = app.secureTextFields["repeatPasswordSecureField"]
        let firstName = app.textFields["firstName"]
        let lastName = app.textFields["lastName"]
        
        // check elements present
        XCTAssertTrue(signupTitle.exists, "The signup page is not displayed")
        XCTAssertTrue(emailField.exists, "The email field is not displayed")
        XCTAssertTrue(passwordSecureField.exists, "The password field is not displayed")
        XCTAssertTrue(repeatPasswordSecureField.exists, "The repeat password field is not displayed")
        XCTAssertTrue(firstName.exists, "The first name field is not displayed")
        XCTAssertTrue(lastName.exists, "The last name field is not displayed")
    }
    
    func testSignUpFailure() {
        // UI elements
        let signupTitle = app.staticTexts["signupTitle"]
        let emailField = app.textFields["emailTextField"]
        let passwordSecureField = app.secureTextFields["passwordSecureField"]
        let repeatPasswordSecureField = app.secureTextFields["repeatPasswordSecureField"]
        let firstName = app.textFields["firstName"]
        let lastName = app.textFields["lastName"]
        let createAccountButton = app.buttons["createAccountButton"]
        let errorMessage = app.staticTexts["errorMessageLabelSignup"]
        
        // check elements present
        XCTAssertTrue(signupTitle.exists, "The signup page is not displayed")
        XCTAssertTrue(emailField.exists, "The email field is not displayed")
        XCTAssertTrue(passwordSecureField.exists, "The password field is not displayed")
        XCTAssertTrue(repeatPasswordSecureField.exists, "The repeat password field is not displayed")
        XCTAssertTrue(firstName.exists, "The first name field is not displayed")
        XCTAssertTrue(lastName.exists, "The last name field is not displayed")
        
        // insert email and password, not repeat password
        emailField.tap()
        emailField.typeText("test@example.com")
        passwordSecureField.tap()
        passwordSecureField.typeText("password_test")
        
        // tap create account button
        createAccountButton.tap()
        
        // check signup page and error message
        XCTAssertTrue(signupTitle.exists, "The signup title image is not displayed")
        XCTAssertTrue(errorMessage.waitForExistence(timeout: timer), "The error message was not displayed")
    }
    
    func testSignUpSuccessful() {
        // UI elements
        let signupTitle = app.staticTexts["signupTitle"]
        let emailField = app.textFields["emailTextField"]
        let passwordSecureField = app.secureTextFields["passwordSecureField"]
        let repeatPasswordSecureField = app.secureTextFields["repeatPasswordSecureField"]
        let firstName = app.textFields["firstName"]
        let lastName = app.textFields["lastName"]
        let createAccountButton = app.buttons["createAccountButton"]
        
        // check elements present
        XCTAssertTrue(signupTitle.exists, "The signup title is not displayed")
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
        firstName.typeText("name")
        app.swipeUp()
        lastName.tap()
        lastName.typeText("last name")
        
        // tap button
        createAccountButton.tap()
        
        // check email verification page and error message
        let emailVerificationPage = app.staticTexts["emailVerificationTitle"]
        XCTAssertTrue(emailVerificationPage.waitForExistence(timeout: timer), "The email verification page is not displayed")
    }
    
    func testSignInWithGoogle() {
        // UI elements
        let googleButton = app.buttons["googleSignInButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        
        app.swipeUp()
        
        // check Google sign in button exists
        XCTAssertTrue(googleButton.waitForExistence(timeout: timer), "The google sign in button is not displayed")
        
        googleButton.tap()
        
        // check page change after login
        XCTAssertTrue(travelSearchViewTitle.waitForExistence(timeout: timer), "TravelSearchView not appeared after sign in with Google")
    }
    
    func testLoginNavigation() {
        // UI elements
        let moveToLoginButton = app.buttons["moveToLoginButton"]
        let loginLogoImage = app.images["loginLogoImage"]
        
        XCTAssertTrue(moveToLoginButton.exists, "The login button is not displayed")
        
        let moveToLoginButtonCenter = moveToLoginButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        app.swipeUp()
        moveToLoginButtonCenter.tap()
        
        XCTAssertTrue(loginLogoImage.waitForExistence(timeout: timer), "Login view did not appear after clicking login button")
    }
}
