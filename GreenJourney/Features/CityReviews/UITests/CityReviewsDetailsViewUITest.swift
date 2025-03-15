import XCTest

final class CityReviewsDetailsViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    let deviceSize = UITestsDeviceSize.deviceSize
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("ui_tests")
        app.launch()
        
        navigateToCityReviewsDetailsView()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    private func navigateToCityReviewsDetailsView() {
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
        
        // UI elements 
        let citiesReviewsTitle = app.staticTexts["citiesReviewsTitle"]
        let bestCity_2 = app.otherElements["bestCityView_2"]
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        
        // check CitiesReviews page
        XCTAssertTrue(citiesReviewsTitle.waitForExistence(timeout: timer), "The citiesReviewsTitle is not displayed")
        XCTAssertTrue(bestCity_2.exists, "bestCity_2 is not displayed")
        
        // tap bestCity_2 button
        bestCity_2.tap()
        
        // check new view
        XCTAssertTrue(selecteCityTitle.exists, "selecteCityTitle is not displayed")
    }
    
    private func addReviewToRoma() {
        // UI elements
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        let addReviewButton = app.buttons["addReviewButton"]
        
        // check and tap button to add a review
        XCTAssertTrue(addReviewButton.exists, "addReviewButton not displayed")
        addReviewButton.tap()
        
        // UI element InsertReviewView
        let personalReviewTitle = app.staticTexts["personalReviewTitle"]
        let userRatings = app.otherElements["userRatings"]
        let userText = app.textFields["userText"]
        let saveButton = app.buttons["saveButton"]
        
        // check element present
        XCTAssertTrue(personalReviewTitle.waitForExistence(timeout: timer), "personalReviewTitle not displayed")
        XCTAssertTrue(userRatings.exists, "userRatings not displayed")
        XCTAssertTrue(userText.exists, "userText not displayed")
        XCTAssertTrue(saveButton.exists, "saveButton not displayed")
        
        // modify ratings
        let star2LocalTransport = app.images.matching(identifier: "star_2").element(boundBy: 0)
        let star4GreenSpaces = app.images.matching(identifier: "star_4").element(boundBy: 1)
        let star1WasteBins = app.images.matching(identifier: "star_1").element(boundBy: 2)
        
        XCTAssertTrue(star2LocalTransport.exists, "star2LocalTransport not displayed")
        XCTAssertTrue(star4GreenSpaces.exists, "star4GreenSpaces not displayed")
        XCTAssertTrue(star1WasteBins.exists, "star1WasteBins not displayed")
        
        // tap stars
        let star2LocalTransportCenter = star2LocalTransport.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let star4GreenSpacesCenter = star4GreenSpaces.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let star1WasteBinsCenter = star1WasteBins.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
    
        star2LocalTransportCenter.tap()
        star4GreenSpacesCenter.tap()
        star1WasteBinsCenter.tap()
        
        // modify text
        userText.tap()
        userText.typeText("This is the review text")
        
        // close keyboard
        let personalReviewTitleCenter = personalReviewTitle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        personalReviewTitleCenter.tap()
        
        // save review
        saveButton.tap()
        
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selecteCityTitle not displayed")
    }
    
    func testCityReviewsDetailsElementsPresentSmallDevice() throws {
        if deviceSize != .small {
            throw XCTSkip("Small devices only")
        }
        // UI elements
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        let averageRatingSection = app.otherElements["averageRatingSection"]
        let addReviewButton = app.buttons["addReviewButton"]
        let yourReviewTitle = app.staticTexts["yourReviewTitle"]
        let userReviewRating = app.otherElements["userReviewRating"]
        let userReviewText = app.staticTexts["userReviewText"]
        let latestReviewsTitle = app.staticTexts["latestReviewsTitle"]
        let reviewElement_17 = app.otherElements["reviewElement_17"]
        let reviewElement_18 = app.otherElements["reviewElement_18"]
        let reviewElement_19 = app.otherElements["reviewElement_19"]
        let reviewElement_20 = app.otherElements["reviewElement_20"]
        let reviewElement_21 = app.otherElements["reviewElement_21"]
        let wrongReviewElement = app.otherElements["reviewElement_16"]
        let allReviewsButton = app.buttons["allReviewsButton"]
        let noReviewsText = app.staticTexts["noReviewsText"]
        
        // check UI elements
        XCTAssertTrue(selecteCityTitle.exists, "selecteCityTitle not displayed")
        XCTAssertTrue(averageRatingSection.exists, "averageRatingSection not displayed")
        
        // there is no review, button present
        XCTAssertTrue(addReviewButton.exists, "addReviewButton not displayed")
        // review data not present
        XCTAssertFalse(yourReviewTitle.exists, "yourReviewTitle displayed")
        XCTAssertFalse(userReviewRating.exists, "userReviewRating displayed")
        XCTAssertFalse(userReviewText.exists, "userReviewText displayed")
        
        // title last reviews
        XCTAssertTrue(latestReviewsTitle.exists, "latestReviewsTitle not displayed")
    
        // some reviews are present
        XCTAssertTrue(reviewElement_17.exists, "reviewElement_17 not displayed")
        reviewElement_17.swipeLeft()
        
        XCTAssertTrue(reviewElement_18.exists, "reviewElement_18 not displayed")
        reviewElement_18.swipeLeft()
        
        XCTAssertTrue(reviewElement_19.exists, "reviewElement_19 not displayed")
        reviewElement_19.swipeLeft()
        
        XCTAssertTrue(reviewElement_20.exists, "reviewElement_20 not displayed")
        reviewElement_20.swipeLeft()
        
        XCTAssertTrue(reviewElement_21.exists, "reviewElement_21 not displayed")
        
        // just 5 reviews should be  displayed
        XCTAssertFalse(wrongReviewElement.exists, "wrongReviewElement not displayed")
        
        // more than 5 reviews present
        XCTAssertTrue(allReviewsButton.exists, "allReviewsButton not displayed")
        XCTAssertFalse(noReviewsText.exists, "noReviewsText displayed")
    }
    
    func testCityReviewsDetailsElementsPresentRegularDevice() throws {
        if deviceSize != .regular {
            throw XCTSkip("Regular devices only")
        }
        // UI elements
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        let averageRatingSection = app.otherElements["averageRatingSection"]
        let addReviewButton = app.buttons["addReviewButton"]
        let yourReviewTitle = app.staticTexts["yourReviewTitle"]
        let userReviewRating = app.otherElements["userReviewRating"]
        let userReviewText = app.staticTexts["userReviewText"]
        let latestReviewsTitle = app.staticTexts["latestReviewsTitle"]
        let reviewElement_16 = app.otherElements["reviewElement_16"]
        let reviewElement_17 = app.otherElements["reviewElement_17"]
        let reviewElement_20 = app.otherElements["reviewElement_20"]
        let reviewElement_21 = app.otherElements["reviewElement_21"]
        let wrongReviewElement = app.otherElements["reviewElement_15"]
        let allReviewsButton = app.buttons["allReviewsButton"]
        let noReviewsText = app.staticTexts["noReviewsText"]
        
        // check UI elements
        XCTAssertTrue(selecteCityTitle.exists, "selecteCityTitle not displayed")
        XCTAssertTrue(averageRatingSection.exists, "averageRatingSection not displayed")
        
        // there is no review, button present
        XCTAssertTrue(addReviewButton.exists, "addReviewButton not displayed")
        // review data not present
        XCTAssertFalse(yourReviewTitle.exists, "yourReviewTitle displayed")
        XCTAssertFalse(userReviewRating.exists, "userReviewRating displayed")
        XCTAssertFalse(userReviewText.exists, "userReviewText displayed")
        
        // title last reviews
        XCTAssertTrue(latestReviewsTitle.exists, "latestReviewsTitle not displayed")
    
        // some reviews are present
        XCTAssertTrue(reviewElement_16.exists, "reviewElement_17 not displayed")
        XCTAssertTrue(reviewElement_17.exists, "reviewElement_18 not displayed")
        XCTAssertTrue(reviewElement_20.exists, "reviewElement_20 not displayed")
        XCTAssertTrue(reviewElement_21.exists, "reviewElement_21 not displayed")

        XCTAssertFalse(wrongReviewElement.exists, "wrongReviewElement not displayed")
        
        // more than 10 reviews present
        XCTAssertTrue(allReviewsButton.exists, "allReviewsButton not displayed")
        XCTAssertFalse(noReviewsText.exists, "noReviewsText displayed")
    }
    
    func testInsertReviewElementsPresent() {
        // both small and regular devices
        
        // UI elements
        let addReviewButton = app.buttons["addReviewButton"]
        
        // check and tap button to add a review
        XCTAssertTrue(addReviewButton.exists, "addReviewButton not displayed")
        addReviewButton.tap()
        
        // UI element InsertReviewView
        let personalReviewTitle = app.staticTexts["personalReviewTitle"]
        let editButton = app.buttons["editButton"]
        let cancelButton = app.buttons["cancelButton"]
        let userRatings = app.otherElements["userRatings"]
        let userText = app.textFields["userText"]
        let saveButton = app.buttons["saveButton"]
        let deleteButton = app.buttons["deleteButton"]
        
        // check element present
        XCTAssertTrue(personalReviewTitle.waitForExistence(timeout: timer), "personalReviewTitle not displayed")
        
        // since a review isn't present, some buttons shouldn't be present
        XCTAssertFalse(editButton.exists, "editButton displayed")
        XCTAssertFalse(deleteButton.exists, "deleteButton displayed")
        
        // elements that should be present
        XCTAssertTrue(cancelButton.exists, "cancelButton not displayed")
        XCTAssertTrue(userRatings.exists, "userRatings not displayed")
        XCTAssertTrue(userText.exists, "userText not displayed")
        XCTAssertTrue(saveButton.exists, "saveButton not displayed")
    }
    
    func testAddReview() {
        // both small and regular devices
        
        // UI elements
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        let addReviewButton = app.buttons["addReviewButton"]
        let yourReviewTitle = app.staticTexts["yourReviewTitle"]
        let userReviewRating = app.otherElements["userReviewRating"]
        let userReviewText = app.staticTexts["userReviewText"]
        
        // check and tap button to add a review
        XCTAssertTrue(addReviewButton.exists, "addReviewButton not displayed")
        addReviewButton.tap()
        
        // UI element InsertReviewView
        let personalReviewTitle = app.staticTexts["personalReviewTitle"]
        let userRatings = app.otherElements["userRatings"]
        let userText = app.textFields["userText"]
        let saveButton = app.buttons["saveButton"]
        
        // check element present
        XCTAssertTrue(personalReviewTitle.waitForExistence(timeout: timer), "personalReviewTitle not displayed")
        XCTAssertTrue(userRatings.exists, "userRatings not displayed")
        XCTAssertTrue(userText.exists, "userText not displayed")
        XCTAssertTrue(saveButton.exists, "saveButton not displayed")
        
        // modify ratings
        let star2LocalTransport = app.images.matching(identifier: "star_2").element(boundBy: 0)
        let star4GreenSpaces = app.images.matching(identifier: "star_4").element(boundBy: 1)
        let star1WasteBins = app.images.matching(identifier: "star_1").element(boundBy: 2)
        
        XCTAssertTrue(star2LocalTransport.exists, "star2LocalTransport not displayed")
        XCTAssertTrue(star4GreenSpaces.exists, "star4GreenSpaces not displayed")
        XCTAssertTrue(star1WasteBins.exists, "star1WasteBins not displayed")
        
        // tap stars
        let star2LocalTransportCenter = star2LocalTransport.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let star4GreenSpacesCenter = star4GreenSpaces.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let star1WasteBinsCenter = star1WasteBins.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
    
        star2LocalTransportCenter.tap()
        star4GreenSpacesCenter.tap()
        star1WasteBinsCenter.tap()
        
        // modify text
        userText.tap()
        userText.typeText("This is the review text")
        
        // close keyboard
        let personalReviewTitleCenter = personalReviewTitle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        personalReviewTitleCenter.tap()
        
        // save review
        saveButton.tap()
        
        // check page change
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selectedCityTitle didn't appear")
        
        // check new review present
        XCTAssertTrue(yourReviewTitle.exists, "yourReviewTitle not displayed")
        XCTAssertTrue(userReviewRating.exists, "userReviewRating not displayed")
        XCTAssertTrue(userReviewText.exists, "userReviewText not displayed")
    }
    
    func testInfoReview() {
        // both small and regular devices
        
        // UI elements
        let infoReviewButton = app.buttons["infoReviewButton"]
        let infoReviewView = app.otherElements["infoReviewView"]
        let infoReviewCloseButton = app.buttons["infoReviewCloseButton"]
        let infoReviewContent = app.otherElements["infoReviewContent"]
        
        // check elements present
        // button present, modal close
        XCTAssertTrue(infoReviewButton.exists, "infoReviewButton not displayed")
        XCTAssertFalse(infoReviewView.exists, "infoReviewView already displayed")
        XCTAssertFalse(infoReviewCloseButton.exists, "infoReviewCloseButton already displayed")
        XCTAssertFalse(infoReviewContent.exists, "infoReviewContent already displayed")
        
        // tap info review button
        let infoReviewButtonCenter = infoReviewButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        infoReviewButtonCenter.tap()
        
        // check elements present
        // modal open
        XCTAssertTrue(infoReviewView.waitForExistence(timeout: timer), "infoReviewView not displayed")
        XCTAssertTrue(infoReviewCloseButton.exists, "infoReviewCloseButton not displayed")
        XCTAssertTrue(infoReviewContent.exists, "infoReviewContent not displayed")
        
        // close info review
        let infoReviewCloseButtonCenter = infoReviewCloseButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        infoReviewCloseButtonCenter.tap()
        
        // check elements present
        // button present, modal close
        XCTAssertTrue(infoReviewButton.exists, "infoReviewButton not displayed")
        XCTAssertFalse(infoReviewView.exists, "infoReviewView already displayed")
        XCTAssertFalse(infoReviewCloseButton.exists, "infoReviewCloseButton already displayed")
        XCTAssertFalse(infoReviewContent.exists, "infoReviewContent already displayed")
    }
    
    func testModifyAndSaveReview() {
        // both small and regular devices
        
        // add a review
        addReviewToRoma()
        
        // UI elements CityReviewsDetails
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        let yourReviewTitle = app.staticTexts["yourReviewTitle"]
        let userReviewRating = app.otherElements["userReviewRating"]
        let userReviewText = app.staticTexts["userReviewText"]
        
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selecteCityTitle not displayed")
        XCTAssertTrue(yourReviewTitle.exists, "yourReviewTitle not displayed")
        XCTAssertTrue(userReviewRating.exists, "userReviewRating not displayed")
        XCTAssertTrue(userReviewText.exists, "userReviewText not displayed")
        
        yourReviewTitle.tap()
        
        // UI element InsertReviewView
        let personalReviewTitle = app.staticTexts["personalReviewTitle"]
        let editButton = app.buttons["editButton"]
        let userRatings = app.otherElements["userRatings"]
        let userText = app.textFields["userText"]
        let saveButton = app.buttons["saveButton"]
        
        XCTAssertTrue(personalReviewTitle.waitForExistence(timeout: timer), "personalReviewTitle not displayed")
        XCTAssertTrue(editButton.exists, "editButton not displayed")
        XCTAssertTrue(userRatings.exists, "userRatings not displayed")
        XCTAssertTrue(userText.exists, "userText not displayed")
        XCTAssertTrue(saveButton.exists, "saveButton not displayed")
        
        // tap edit button
        let editButtonCenter = editButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        editButtonCenter.tap()
        
        // modify review text
        userText.tap()
        userText.typeText("add some text")
        
        // close keyboard
        let personalReviewTitleCenter = personalReviewTitle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        personalReviewTitleCenter.tap()
        
        // click save button
        saveButton.tap()
        
        // check view
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selecteCityTitle not displayed")
    }
     
    func testModifyAndCancelReview() {
        // both small and regular devices
        
        // add a review
        addReviewToRoma()
        
        // UI elements CityReviewsDetails
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        let yourReviewTitle = app.staticTexts["yourReviewTitle"]
        let userReviewRating = app.otherElements["userReviewRating"]
        let userReviewText = app.staticTexts["userReviewText"]
        
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selecteCityTitle not displayed")
        XCTAssertTrue(yourReviewTitle.exists, "yourReviewTitle displayed")
        XCTAssertTrue(userReviewRating.exists, "userReviewRating displayed")
        XCTAssertTrue(userReviewText.exists, "userReviewText displayed")
        
        yourReviewTitle.tap()
        
        // UI element InsertReviewView
        let personalReviewTitle = app.staticTexts["personalReviewTitle"]
        let editButton = app.buttons["editButton"]
        let userRatings = app.otherElements["userRatings"]
        let userText = app.textFields["userText"]
        let cancelButton = app.buttons["cancelButton"]
        
        XCTAssertTrue(personalReviewTitle.waitForExistence(timeout: timer), "personalReviewTitle not displayed")
        XCTAssertTrue(editButton.exists, "editButton not displayed")
        XCTAssertTrue(userRatings.exists, "userRatings not displayed")
        XCTAssertTrue(userText.exists, "userText not displayed")
        XCTAssertTrue(cancelButton.exists, "saveButton not displayed")
        
        // tap edit button
        // tap edit button
        let editButtonCenter = editButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        editButtonCenter.tap()
        
        // modify review text
        userText.tap()
        userText.typeText("add some text")
        
        // close keyboard
        let personalReviewTitleCenter = personalReviewTitle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        personalReviewTitleCenter.tap()
        
        // click cancel button
        let cancelButtonCenter = cancelButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        cancelButtonCenter.tap()
        
        // check view
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selecteCityTitle not displayed")
    }
    
    func testDeleteReview() {
        // add a review
        addReviewToRoma()
        
        // UI elements CityReviewsDetails
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        let yourReviewTitle = app.staticTexts["yourReviewTitle"]
        let userReviewRating = app.otherElements["userReviewRating"]
        let userReviewText = app.staticTexts["userReviewText"]
        
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selecteCityTitle not displayed")
        XCTAssertTrue(yourReviewTitle.exists, "yourReviewTitle displayed")
        XCTAssertTrue(userReviewRating.exists, "userReviewRating displayed")
        XCTAssertTrue(userReviewText.exists, "userReviewText displayed")
        
        yourReviewTitle.tap()
        
        // UI element InsertReviewView
        let personalReviewTitle = app.staticTexts["personalReviewTitle"]
        let deleteButton = app.buttons["deleteButton"]
        
        XCTAssertTrue(personalReviewTitle.waitForExistence(timeout: timer), "personalReviewTitle not displayed")
        XCTAssertTrue(deleteButton.exists, "deleteButton not displayed")
        
        // tap delete button
        deleteButton.tap()
        
        let deleteAlert = app.alerts.firstMatch
        XCTAssertTrue(deleteAlert.waitForExistence(timeout: timer), "The alert was not shown")
        
        let cancelButtonAlert = deleteAlert.buttons["Cancel"]
        let deleteButtonAlert = deleteAlert.buttons["Delete"]
        XCTAssertTrue(cancelButtonAlert.exists, "The cancel button is not present")
        XCTAssertTrue(deleteButtonAlert.exists, "The delete button is not present")
        
        deleteButtonAlert.tap()
        
        // check view update
        XCTAssertFalse(deleteAlert.exists, "The alert is displayed and should not")
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selecteCityTitle not displayed")
    }
    
    func testSeeAllReviews() {
        // both small and regular devices
        
        // UI elements
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        let allReviewsButton = app.buttons["allReviewsButton"]
        
        // check existence
        XCTAssertTrue(selecteCityTitle.exists, "selecteCityTitle not displayed")
        XCTAssertTrue(allReviewsButton.exists, "allReviewsButton not displayed")
        
        // tap all reviews button
        allReviewsButton.tap()
        
        // check page
        let cityName = app.staticTexts["cityName"]
        
        // check page
        XCTAssertTrue(cityName.waitForExistence(timeout: timer), "cityName not displayed")
    }
}
