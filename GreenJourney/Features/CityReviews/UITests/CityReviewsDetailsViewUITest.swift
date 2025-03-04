import XCTest

final class CityReviewsDetailsViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    
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
        
        let citiesReviewsTabButton = app.tabBars.buttons["citiesReviewsTabViewElement"]
        
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
        let selecteCityTitleCenter = selecteCityTitle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        selecteCityTitleCenter.tap()
        
        // save review
        saveButton.tap()
        
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selecteCityTitle not displayed")
    }
    
    func testCityReviewsDetailsElementsPresent() {
        // UI elements
        let selecteCityTitle = app.staticTexts["selecteCityTitle"]
        let averageRatingSection = app.otherElements["averageRatingSection"]
        let addReviewButton = app.buttons["addReviewButton"]
        let yourReviewTitle = app.staticTexts["yourReviewTitle"]
        let userReviewRating = app.otherElements["userReviewRating"]
        let userReviewText = app.staticTexts["userReviewText"]
        let lastReviewsTitle = app.staticTexts["latestReviewsTitle"]
        let firstReviewElement = app.otherElements["reviewElement_17"]
        let secondReviewElement = app.otherElements["reviewElement_18"]
        let thirdReviewElement = app.otherElements["reviewElement_19"]
        let fourthReviewElement = app.otherElements["reviewElement_20"]
        let lastReviewElement = app.otherElements["reviewElement_21"]
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
        
        // some reviews are present
        XCTAssertTrue(lastReviewsTitle.exists, "lastReviewsTitle not displayed")
        XCTAssertTrue(firstReviewElement.exists, "firstReviewElement not displayed")
        XCTAssertTrue(secondReviewElement.exists, "secondReviewElement not displayed")
        XCTAssertTrue(thirdReviewElement.exists, "thirdReviewElement not displayed")
        
        // swipe
        firstReviewElement.swipeLeft()
        secondReviewElement.swipeLeft()
        thirdReviewElement.swipeLeft()
        
        XCTAssertTrue(fourthReviewElement.exists, "thirdReviewElement not displayed")
        
        fourthReviewElement.swipeLeft()
        
        XCTAssertTrue(lastReviewElement.waitForExistence(timeout: timer), "lastReviewElement not displayed")
        // just 5 reviews should be  displayed
        XCTAssertFalse(wrongReviewElement.exists, "wrongReviewElement not displayed")
        
        // more than 5 reviews present
        XCTAssertTrue(allReviewsButton.exists, "allReviewsButton not displayed")
        XCTAssertFalse(noReviewsText.exists, "noReviewsText displayed")
    }
    
    func testInsertReviewElementsPresent() {
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
        let selecteCityTitleCenter = selecteCityTitle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        selecteCityTitleCenter.tap()
        
        // save review
        saveButton.tap()
        
        // check page change
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selectedCityTitle didn't appear")
        
        // check new review present
        XCTAssertTrue(yourReviewTitle.exists, "yourReviewTitle not displayed")
        XCTAssertTrue(userReviewRating.exists, "userReviewRating not displayed")
        XCTAssertTrue(userReviewText.exists, "userReviewText not displayed")
    }
    
    func testModifyAndSaveReview() {
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
        let selecteCityTitleCenter = selecteCityTitle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        selecteCityTitleCenter.tap()
        
        // click save button
        saveButton.tap()
        
        // check view
        XCTAssertTrue(selecteCityTitle.waitForExistence(timeout: timer), "selecteCityTitle not displayed")
    }
     
    func testModifyAndCancelReview() {
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
        let selecteCityTitleCenter = selecteCityTitle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        selecteCityTitleCenter.tap()
        
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
