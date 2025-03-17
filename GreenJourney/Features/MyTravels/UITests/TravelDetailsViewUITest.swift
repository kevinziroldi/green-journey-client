import XCTest

final class TravelDetailsViewUITest: XCTestCase {
    let app = XCUIApplication()
    let timer = 5.0
    let deviceSize = UITestsDeviceSize.deviceSize
    
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
        
        // tap button
        if deviceSize == .compact {
            let myTravelsTabButton = app.tabBars.buttons["myTravelsTabViewElement"]
            myTravelsTabButton.tap()
        } else {
            // .regular
            let app = XCUIApplication()
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.5))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5))
            start.press(forDuration: 0.1, thenDragTo: end)
            
            let citiesReviewsTabButton = app.otherElements["myTravelsTabViewElement"]
            XCTAssertTrue(citiesReviewsTabButton.exists)
            citiesReviewsTabButton.tap()
            
            let right = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
            right.tap()
        }
        
        // check MyTravels page
        XCTAssertTrue(myTravelsTitle.waitForExistence(timeout: timer), "MyTravelsView not appeared after selecting it")
    }
    
    func testTravelDetailsViewElementsExistTravelConfirmed() {
        navigateToTravelDetailsViewTravelConfirmed()
        
        // UI elements
        let headerView = app.otherElements["headerView"]
        let travelRecap = app.otherElements["travelRecap"]
        let infoCompensationButton = app.buttons["infoCompensationButton"]
        let infoGreenPriceButton = app.buttons["infoGreenPriceButton"]
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
    
        XCTAssertTrue(infoCompensationButton.exists, "infoCompensationButton not displayed")
        XCTAssertTrue(plusTreesButton.exists, "plusTreesButton not displayed")
        XCTAssertTrue(minusTreesButton.exists, "minusTreesButton not displayed")
        XCTAssertTrue(compensateButton.exists, "compensateButton not displayed")
        
        XCTAssertTrue(travelRecap.exists, "travelRecap not displayed")
        XCTAssertTrue(infoGreenPriceButton.exists, "infoGreenPriceButton not displayed")
        
        XCTAssertFalse(emissionsRecapFutureTravel.exists, "emission recap displyed for a confirmed travel")
        
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
        let infoCompensationButton = app.buttons["infoCompensationButton"]
        let infoCompensationView = app.otherElements["infoCompensationView"]
        let infoCompensationContent = app.otherElements["infoCompensationContent"]
        let infoCloseButton = app.buttons["infoCloseButton"]
        
        // check elements displayed
        // info button present
        XCTAssertTrue(infoCompensationButton.exists, "infoCompensationButton not displayed")
        // modal closed
        XCTAssertFalse(infoCompensationView.exists, "infoCompensationView already displayed")
        XCTAssertFalse(infoCompensationContent.exists, "infoCompensationContent already displayed")
        XCTAssertFalse(infoCloseButton.exists, "infoCloseButton already displayed")
        
        // tap info button
        infoCompensationButton.tap()
        
        // check elements displayed
        // modal open
        XCTAssertTrue(infoCompensationView.waitForExistence(timeout: timer), "infoCompensationView not displayed")
        XCTAssertTrue(infoCompensationContent.exists, "infoText not displayed")
        XCTAssertTrue(infoCloseButton.exists, "infoCloseButton not displayed")
        
        // close info section
        let infoCloseButtonCenter = infoCloseButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        infoCloseButtonCenter.tap()
        
        // check elements displayed
        // modal close
        XCTAssertTrue(infoCompensationButton.exists, "infoCompensationButton not displayed")
        XCTAssertFalse(infoCompensationView.exists, "infoCompensationView already displayed")
        XCTAssertFalse(infoCompensationContent.exists, "infoText already displayed")
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
    
    func testInoGreenPrice() {
        navigateToTravelDetailsViewTravelConfirmed()
        
        // UI elements
        let infoGreenPriceButton = app.buttons["infoGreenPriceButton"]
        let infoGreenPriceView = app.otherElements["infoGreenPriceView"]
        let infoGreenPriceContent = app.otherElements["infoGreenPriceContent"]
        let infoGreenPriceCloseButton = app.buttons["infoGreenPriceCloseButton"]
        
        // check elements displayed
        // info button present
        XCTAssertTrue(infoGreenPriceButton.exists, "infoGreenPriceButton not displayed")
        // modal closed
        XCTAssertFalse(infoGreenPriceView.exists, "infoGreenPriceView already displayed")
        XCTAssertFalse(infoGreenPriceContent.exists, "infoGreenPriceContent already displayed")
        XCTAssertFalse(infoGreenPriceCloseButton.exists, "infoGreenPriceCloseButton already displayed")
        
        // tap info button
        let infoGreenPriceButtonCenter = infoGreenPriceButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        infoGreenPriceButtonCenter.tap()
        
        // check elements displayed
        // modal open
        XCTAssertTrue(infoGreenPriceView.waitForExistence(timeout: timer), "infoGreenPriceView not displayed")
        XCTAssertTrue(infoGreenPriceContent.exists, "infoGreenPriceContent not displayed")
        XCTAssertTrue(infoGreenPriceCloseButton.exists, "infoGreenPriceCloseButton not displayed")
        
        // close info section
        let infoGreenPriceCloseButtonCenter = infoGreenPriceCloseButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        infoGreenPriceCloseButtonCenter.tap()
        
        // check elements displayed
        // modal close
        XCTAssertTrue(infoGreenPriceButton.exists, "infoGreenPriceButton not displayed")
        XCTAssertFalse(infoGreenPriceView.exists, "infoGreenPriceView already displayed")
        XCTAssertFalse(infoGreenPriceContent.exists, "infoGreenPriceContent already displayed")
        XCTAssertFalse(infoGreenPriceCloseButton.exists, "infoCloseButton already displayed")
    }
    
    func testReviewButton() {
        navigateToTravelDetailsViewTravelConfirmed()
     
        let headerView = app.otherElements["headerView"]
        let reviewButton = app.buttons["reviewButton"]
        
        XCTAssertTrue(headerView.waitForExistence(timeout: timer), "The header view is not displayed")
        XCTAssertTrue(reviewButton.exists, "The review button is not displayed")
        
        reviewButton.tap()
        
        let personalReviewTitle = app.staticTexts["personalReviewTitle"]
        XCTAssertTrue(personalReviewTitle.waitForExistence(timeout: timer), "Review page didn't appear")
    }
    
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
