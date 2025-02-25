import XCTest

final class TravelDetailsViewUITest: XCTestCase {
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
    
    private func navigateToTravelDetailsViewTravelNotConfirmed() {
        navigateToMyTravelsView()
        
        // UI elements
        let travelCardButton = app.buttons.matching(identifier: "travelCardButton_115").firstMatch
        // check travel card present
        XCTAssertTrue(travelCardButton.waitForExistence(timeout: timer), "The travel card was not found")
        
        // tap travel card
        travelCardButton.tap()
        
        // check travel details view
        let headerView = app.otherElements["headerView"]
        XCTAssertTrue(headerView.waitForExistence(timeout: timer), "The travel details view was not displayed")
    }
    
    private func navigateToTravelDetailsViewTravelConfirmed() {
        navigateToMyTravelsView()
        
        // UI elements
        let travelCardButton = app.buttons.matching(identifier: "travelCardButton_116").firstMatch
        // check travel card present
        XCTAssertTrue(travelCardButton.waitForExistence(timeout: timer), "The travel card was not found")
        
        // tap travel card
        travelCardButton.tap()
        
        // check travel details view
        let headerView = app.otherElements["headerView"]
        XCTAssertTrue(headerView.waitForExistence(timeout: timer), "The travel details view was not displayed")
    }
    
    private func navigateToMyTravelsView() {
        // UI elements
        let emailTextField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        let travelSearchViewTitle = app.staticTexts["travelSearchViewTitle"]
        let myTravelsTabButton = app.tabBars.buttons["myTravelsTabViewElement"]
        let myTravelsTitle = app.staticTexts["myTravelsTitle"]
       
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
        myTravelsTabButton.tap()
        
        // check MyTravels page
        XCTAssertTrue(myTravelsTitle.waitForExistence(timeout: timer), "MyTravelsView not appeared after selecting it")
    }
    
    func testTravelDetailsViewElementsExistTravelConfirmed() {
        navigateToTravelDetailsViewTravelConfirmed()
        
        // UI elements
        let headerView = app.otherElements["headerView"]
        let travelRecap = app.otherElements["travelRecap"]
        let infoButton = app.buttons["infoButton"]
        let plusTreesButton = app.buttons["plusButton"]
        let minusTreesButton = app.buttons["minusButton"]
        let compensateButton = app.buttons["compensateButton"]
        let reviewButton = app.buttons["reviewButton"]
        let trashButton = app.buttons["trashButton"]
        let outwardSegmentsTitle = app.staticTexts["segmentsTitle"]
        let outwardSegmentsView = app.otherElements["outwardSegmentsView"]
        let returnSegmentsTitle = app.staticTexts["returnTitle"]
        let returnSegmentsView = app.otherElements["returnSegmentsView"]
        let emissionsRecapFutureTravel = app.otherElements["emissionsRecapFutureTravel"]
        
        // check elements present
        XCTAssertTrue(headerView.exists, "headerView not displayed")
        XCTAssertTrue(travelRecap.exists, "travelRecap not displayed")
        XCTAssertFalse(emissionsRecapFutureTravel.exists, "emission recap displyed for a confirmed travel")
        
        XCTAssertTrue(infoButton.exists, "infoButton not displayed")
        XCTAssertTrue(plusTreesButton.exists, "plusTreesButton not displayed")
        XCTAssertTrue(minusTreesButton.exists, "minusTreesButton not displayed")
        XCTAssertTrue(compensateButton.exists, "compensateButton not displayed")
       
        XCTAssertTrue(reviewButton.exists, "reviewButton not displayed")
        XCTAssertTrue(trashButton.exists, "trashButton not displayed")
        
        app.swipeUp()
        
        XCTAssertTrue(outwardSegmentsTitle.exists, "outwardSegmentsTitle not displayed")
        XCTAssertTrue(outwardSegmentsView.exists, "outwardSegmentsView not displayed")
        XCTAssertTrue(returnSegmentsTitle.waitForExistence(timeout: timer), "HeaderView not displayed")
        XCTAssertTrue(returnSegmentsView.exists, "HeaderView not displayed")
    }
    
    func testTravelDetailsViewElementsExistTravelNotConfirmed() {
        navigateToTravelDetailsViewTravelNotConfirmed()
        
        // UI elements
        let headerView = app.otherElements["headerView"]
        let travelRecap = app.otherElements["travelRecap"]
        let infoButton = app.buttons["infoButton"]
        let plusTreesButton = app.buttons["plusButton"]
        let minusTreesButton = app.buttons["minusButton"]
        let compensateButton = app.buttons["compensateButton"]
        let reviewButton = app.buttons["reviewButton"]
        let trashButton = app.buttons["trashButton"]
        let outwardSegmentsTitle = app.staticTexts["segmentsTitle"]
        let outwardSegmentsView = app.otherElements["outwardSegmentsView"]
        let returnSegmentsTitle = app.staticTexts["returnTitle"]
        let returnSegmentsView = app.otherElements["returnSegmentsView"]
        let emissionsRecapFutureTravel = app.otherElements["emissionsRecapFutureTravel"]
        
        // check emission section not present
        XCTAssertFalse(infoButton.exists, "infoButton displayed")
        XCTAssertFalse(plusTreesButton.exists, "plusTreesButton displayed")
        XCTAssertFalse(minusTreesButton.exists, "minusTreesButton displayed")
        XCTAssertFalse(compensateButton.exists, "compensateButton displayed")
        XCTAssertFalse(reviewButton.exists, "reviewButton not displayed")
        
        // check elements present
        XCTAssertTrue(headerView.exists, "headerView not displayed")
        XCTAssertTrue(travelRecap.exists, "travelRecap not displayed")
        XCTAssertTrue(emissionsRecapFutureTravel.exists, "emission recap displyed for a confirmed travel")
        XCTAssertTrue(trashButton.exists, "trashButton not displayed")
        
        app.swipeUp()
        
        XCTAssertTrue(outwardSegmentsTitle.exists, "outwardSegmentsTitle not displayed")
        XCTAssertTrue(outwardSegmentsView.exists, "outwardSegmentsView not displayed")
        XCTAssertTrue(returnSegmentsTitle.waitForExistence(timeout: timer), "HeaderView not displayed")
        XCTAssertTrue(returnSegmentsView.exists, "HeaderView not displayed")
    }
    
    func testInfoButtonOpensAndClosesInfoView() {
        navigateToTravelDetailsViewTravelConfirmed()
        
        // UI elements
        let infoButton = app.buttons["infoButton"]
        let infoCompensationView = app.otherElements["infoCompensationView"]
        let infoText = app.staticTexts["infoText"]
        let infoCloseButton = app.buttons["infoCloseButton"]
        
        // check elements displayed
        XCTAssertTrue(infoButton.exists, "infoCompensationView not displayed")
        XCTAssertFalse(infoCompensationView.exists, "infoCompensationView already displayed")
        XCTAssertFalse(infoText.exists, "infoText already displayed")
        XCTAssertFalse(infoCloseButton.exists, "infoCloseButton already displayed")
        
        // tap info button
        infoButton.tap()
        
        // check elements displayed
        XCTAssertTrue(infoCompensationView.waitForExistence(timeout: timer), "infoCompensationView not displayed")
        XCTAssertTrue(infoText.exists, "infoText not displayed")
        XCTAssertTrue(infoCloseButton.exists, "infoCloseButton not displayed")
        
        // close info section
        infoCloseButton.tap()
        
        // check elements displayed
        XCTAssertTrue(infoButton.exists, "infoCompensationView not displayed")
        XCTAssertFalse(infoCompensationView.exists, "infoCompensationView already displayed")
        XCTAssertFalse(infoText.exists, "infoText already displayed")
        XCTAssertFalse(infoCloseButton.exists, "infoCloseButton already displayed")
    }

    func testIncrementAndDecrementTrees() {
        navigateToTravelDetailsViewTravelConfirmed()
        let plusTreesButton = app.buttons["plusButton"]
        let minusTreesButton = app.buttons["minusButton"]
        let compensateButton = app.buttons["compensateButton"]
        
        XCTAssertTrue(plusTreesButton.waitForExistence(timeout: timer), "The plus button is not displayed")
        XCTAssertTrue(minusTreesButton.waitForExistence(timeout: timer), "The minus button is not displayed")
        XCTAssertTrue(compensateButton.exists, "The compensate button is not displayed")
        
        plusTreesButton.tap()
        minusTreesButton.tap()
        compensateButton.tap()
        
        XCTAssertTrue(plusTreesButton.waitForExistence(timeout: timer), "The plus button is not displayed")
        XCTAssertTrue(minusTreesButton.waitForExistence(timeout: timer), "The minus button is not displayed")
        XCTAssertTrue(compensateButton.exists, "The compensate button is not displayed")
    }
    
    func testCompensateButtonTap() {
        navigateToTravelDetailsViewTravelConfirmed()
     
        let plusTreesButton = app.buttons["plusButton"]
        let minusTreesButton = app.buttons["minusButton"]
        let compensateButton = app.buttons["compensateButton"]
        
        XCTAssertTrue(plusTreesButton.waitForExistence(timeout: timer), "The plus button is not displayed")
        XCTAssertTrue(minusTreesButton.waitForExistence(timeout: timer), "The minus button is not displayed")
        XCTAssertTrue(compensateButton.exists, "The compensate button is not displayed")
        
        plusTreesButton.tap()
        compensateButton.tap()
        
        XCTAssertTrue(plusTreesButton.waitForExistence(timeout: timer), "The plus button is not displayed")
        XCTAssertTrue(minusTreesButton.waitForExistence(timeout: timer), "The minus button is not displayed")
        XCTAssertTrue(compensateButton.exists, "The compensate button is not displayed")
    }
    
    /*
    func testReviewButton() {
        navigateToTravelDetailsViewTravelConfirmed()
     
        let headerView = app.otherElements["headerView"]
        let reviewButton = app.buttons["reviewButton"]
        
        XCTAssertTrue(headerView.waitForExistence(timeout: timer), "The header view is not displayed")
        XCTAssertTrue(reviewButton.exists, "The review button is not displayed")
        
        reviewButton.tap()
        
        // TODO manca view annidata
        XCTAssertFalse(headerView.waitForExistence(timeout: timer), "The header view is still displayed")
        // TODO check view annidata
    }
     */
    
    func testTrashButtonAlert() {
        navigateToTravelDetailsViewTravelConfirmed()
        
        let trashButton = app.buttons["trashButton"]
        XCTAssertTrue(trashButton.waitForExistence(timeout: timer), "The trash button is not displayed")
        
        app.swipeUp()
        
        trashButton.tap()
        
        let deleteAlert = app.alerts.firstMatch
        XCTAssertTrue(deleteAlert.waitForExistence(timeout: timer), "The alert was not shown")
        
        let cancelButton = deleteAlert.buttons["Cancel"]
        let deleteButton = deleteAlert.buttons["Delete"]
        XCTAssertTrue(cancelButton.exists, "The cancel button is not present")
        XCTAssertTrue(deleteButton.exists, "The delete button is not present")
        
        cancelButton.tap()
        
        XCTAssertFalse(deleteAlert.exists, "The alert is displayed and should not")
    }
}
