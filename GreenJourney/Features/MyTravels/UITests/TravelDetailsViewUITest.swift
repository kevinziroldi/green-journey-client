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
    
    private func navigateToTravelDetailsView() {
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
        
        // UI elements
        let travelCardButton = app.buttons.matching(identifier: "travelCardButton_107").firstMatch
        // check travel card present
        XCTAssertTrue(travelCardButton.waitForExistence(timeout: timer), "The travel card was not found")
        
        // tap travel card
        travelCardButton.tap()
        
        // check travel details view
        let headerView = app.otherElements["headerView"]
        XCTAssertTrue(headerView.waitForExistence(timeout: timer), "The travel details view was not displayed")
    }
    
    func testEmpty() {
        
    }
    
    /*
    func testInfoButtonOpensAndClosesInfoView() {
        // Trova e tocca il bottone info
        let infoButton = app.buttons["infoButton"]
        XCTAssertTrue(infoButton.waitForExistence(timeout: 2), "Il bottone info dovrebbe esistere")
        infoButton.tap()
        
        // Verifica che la InfoCompensationView sia visualizzata
        let infoView = app.otherElements["infoCompensationView"]
        XCTAssertTrue(infoView.waitForExistence(timeout: 2), "La vista info dovrebbe apparire")
        
        // Chiude la vista
        let closeButton = app.buttons["infoCloseButton"]
        XCTAssertTrue(closeButton.exists, "Il bottone di chiusura dovrebbe esistere")
        closeButton.tap()
        XCTAssertFalse(infoView.exists, "La vista info dovrebbe essere chiusa")
    }
    
    func testIncrementAndDecrementTrees() {
        let plusButton = app.buttons["plusButton"]
        let minusButton = app.buttons["minusButton"]
        let treesCountLabel = app.staticTexts["treesCountLabel"]
        
        XCTAssertTrue(plusButton.waitForExistence(timeout: 2), "Il bottone '+' dovrebbe esistere")
        XCTAssertTrue(minusButton.exists, "Il bottone '-' dovrebbe esistere")
        XCTAssertTrue(treesCountLabel.exists, "La label del conteggio degli alberi dovrebbe esistere")
        
        // Cattura il valore iniziale
        let initialValue = treesCountLabel.label
        
        plusButton.tap()
        // Attendi il cambiamento (eventualmente con una pausa o aspettando un'animazione)
        sleep(1)
        let incrementedValue = treesCountLabel.label
        XCTAssertNotEqual(initialValue, incrementedValue, "Il conteggio degli alberi dovrebbe incrementare")
        
        minusButton.tap()
        sleep(1)
        let decrementedValue = treesCountLabel.label
        XCTAssertEqual(initialValue, decrementedValue, "Il conteggio degli alberi dovrebbe tornare al valore iniziale")
    }
    
    func testCompensateButton() {
        let compensateButton = app.buttons["compensateButton"]
        XCTAssertTrue(compensateButton.waitForExistence(timeout: 2), "Il bottone di compensazione dovrebbe esistere")
        compensateButton.tap()
        // Aggiungi ulteriori verifiche se l'azione porta a cambiamenti visibili nell'UI
    }
    
    func testReviewButton() {
        let reviewButton = app.buttons["reviewButton"]
        XCTAssertTrue(reviewButton.waitForExistence(timeout: 2), "Il bottone review dovrebbe esistere")
        reviewButton.tap()
        // Aggiungi verifiche per l'azione di review se implementata
    }
    
    func testTrashButtonAlert() {
        let trashButton = app.buttons["trashButton"]
        XCTAssertTrue(trashButton.waitForExistence(timeout: 2), "Il bottone trash dovrebbe esistere")
        trashButton.tap()
        
        let deleteAlert = app.alerts.firstMatch
        XCTAssertTrue(deleteAlert.waitForExistence(timeout: 2), "L'alert di cancellazione dovrebbe apparire")
        
        let cancelButton = deleteAlert.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists, "Il bottone Cancel dovrebbe esistere nell'alert")
        cancelButton.tap()
        XCTAssertFalse(deleteAlert.exists, "L'alert dovrebbe essere chiuso dopo aver premuto Cancel")
    }
     */
}
