//
//  SocialQRUITests.swift
//  SocialQRUITests
//
//  Created by Rahul Yedida on 11/16/20.
//

import XCTest

class SocialQRUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFirstStartupUI() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.

        XCTAssertTrue(app.staticTexts["Welcome!"].exists)
        XCTAssertTrue(app.textFields["Name"].exists)
        XCTAssertTrue(app.textFields["Phone"].exists)
        XCTAssertTrue(app.buttons["Continue!"].exists)
        
        XCTAssertFalse(app.staticTexts["Nearby"].exists)
        XCTAssertFalse(app.staticTexts["Requests (0)"].exists)
        XCTAssertFalse(app.staticTexts["Near Me"].exists)
        XCTAssertFalse(app.staticTexts["Friends"].exists)
        XCTAssertFalse(app.staticTexts["Profile"].exists)
        XCTAssertFalse(app.staticTexts["Settings"].exists)
    }
    
    func testStartupUI() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.

        XCTAssertTrue(app.staticTexts["Welcome!"].exists)
        XCTAssertTrue(app.textFields["Name"].exists)
        XCTAssertTrue(app.textFields["Phone"].exists)
        XCTAssertTrue(app.buttons["Continue!"].exists)
        app.textFields["Name"].tap()
        app.textFields["Name"].typeText("Russell")
        app.textFields["Phone"].tap()
        app.buttons["Continue!"].tap()
        
        XCTAssertFalse(app.staticTexts["Nearby"].exists)
        XCTAssertFalse(app.staticTexts["Requests (0)"].exists)
        XCTAssertFalse(app.staticTexts["Near Me"].exists)
        XCTAssertFalse(app.staticTexts["Friends"].exists)
        XCTAssertFalse(app.staticTexts["Profile"].exists)
        XCTAssertFalse(app.staticTexts["Settings"].exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
