import XCTest

final class AllReviewsViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    let deviceSize = UITestsDeviceSize.deviceSize
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        navigateToAllReviewsView()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToAllReviewsView() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        
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
        if deviceSize == .compact {
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
        
        // UI elements
        let citiesReviewsTitle = app.staticTexts["citiesReviewsTitle"]
        let bestCity_2 = app.otherElements["bestCityView_2"]
        
        // check CitiesReviews page
        XCTAssertTrue(citiesReviewsTitle.waitForExistence(timeout: timer), "The citiesReviewsTitle is not displayed")
        XCTAssertTrue(bestCity_2.exists, "bestCity_2 is not displayed")
        
        // tap bestCity_2 button
        bestCity_2.tap()
        
        // all reviews button
        let allReviewsButton = app.buttons["allReviewsButton"]
        XCTAssertTrue(allReviewsButton.waitForExistence(timeout: timer), "allReviewsButton not appeared")
        
        // tap all reviews button
        allReviewsButton.tap()
    }
    
    func testAllReviewViewElementsPresent() {
        // UI elements
        let cityName = app.staticTexts["cityName"]
        let buttonFirst = app.buttons["buttonFirst"]
        let buttonPrevious = app.buttons["buttonPrevious"]
        let buttonNext = app.buttons["buttonNext"]
        let buttonLast = app.buttons["buttonLast"]
        let doneButton = app.buttons["doneButton"]
        let firstPageReview = app.otherElements["reviewView_21"]
        let secondPageReview = app.otherElements["reviewView_11"]
        
        // check elements of the view
        XCTAssertTrue(cityName.waitForExistence(timeout: timer), "cityName not displayed")
        
        XCTAssertTrue(buttonFirst.exists, "buttonFirst not displayed")
        XCTAssertTrue(buttonPrevious.exists, "buttonPrevious not displayed")
        XCTAssertTrue(buttonNext.exists, "buttonNext not displayed")
        XCTAssertTrue(buttonLast.exists, "buttonLast not displayed")
        XCTAssertFalse(doneButton.exists, "doneButton already displayed")
        
        XCTAssertTrue(firstPageReview.exists, "firstPageReview not displayed")
        XCTAssertFalse(secondPageReview.exists, "secondPageReview already displayed")
    }
    
    func testMoveToNextPage() {
        // UI elements
        let buttonNext = app.buttons["buttonNext"]
        let firstPageReview = app.otherElements["reviewView_21"]
        let secondPageReview = app.otherElements["reviewView_11"]
        
        // check first page and button present
        XCTAssertTrue(firstPageReview.exists, "firstPageReview not displayed")
        XCTAssertTrue(buttonNext.exists, "buttonNext not displayed")
        
        // tap Next button
        buttonNext.tap()
        
        // check second page
        XCTAssertTrue(secondPageReview.exists, "secondPageReview not displayed")
    }
    
    func testMoveToLastPage() {
        // UI elements
        let buttonLast = app.buttons["buttonLast"]
        let firstPageReview = app.otherElements["reviewView_21"]
        let secondPageReview = app.otherElements["reviewView_11"]
        
        // check first page and button present
        XCTAssertTrue(firstPageReview.exists, "firstPageReview not displayed")
        XCTAssertTrue(buttonLast.exists, "buttonLast not displayed")
        
        // tap Next button
        buttonLast.tap()
        
        // check second page
        XCTAssertTrue(secondPageReview.exists, "secondPageReview not displayed")
    }
    
    func testMoveToPreviousPage() {
        // UI elements
        let buttonLast = app.buttons["buttonLast"]
        let buttonPrevious = app.buttons["buttonPrevious"]
        let firstPageReview = app.otherElements["reviewView_20"]
        let secondPageReview = app.otherElements["reviewView_11"]
        
        // check first page and button present
        XCTAssertTrue(firstPageReview.exists, "firstPageReview not displayed")
        XCTAssertTrue(buttonLast.exists, "buttonLast not displayed")
        
        // tap Next button
        buttonLast.tap()
        
        // check second page
        XCTAssertTrue(secondPageReview.exists, "secondPageReview not displayed")
        
        // check Previous button present
        XCTAssertTrue(buttonPrevious.exists, "buttonPrevious not displayed")
        
        // tap button
        buttonPrevious.tap()
        
        // check first page
        XCTAssertTrue(firstPageReview.exists, "firstPageReview not displayed")
    }
    
    func testMoveToFirstPage() {
        // UI elements
        let buttonLast = app.buttons["buttonLast"]
        let buttonFirst = app.buttons["buttonFirst"]
        let firstPageReview = app.otherElements["reviewView_20"]
        let secondPageReview = app.otherElements["reviewView_11"]
        
        // check first page and button present
        XCTAssertTrue(firstPageReview.exists, "firstPageReview not displayed")
        XCTAssertTrue(buttonLast.exists, "buttonLast not displayed")
        
        // tap Next button
        buttonLast.tap()
        
        // check second page
        XCTAssertTrue(secondPageReview.exists, "secondPageReview not displayed")
        
        // check Previous button present
        XCTAssertTrue(buttonFirst.exists, "buttonFirst not displayed")
        
        // tap button
        buttonFirst.tap()
        
        // check first page
        XCTAssertTrue(firstPageReview.exists, "firstPageReview not displayed")
    }
}
