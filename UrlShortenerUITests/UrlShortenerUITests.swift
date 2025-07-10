//
//  UrlShortenerUITests.swift
//  UrlShortenerUITests
//
//  Created 07/08/25.
//

import XCTest

final class UrlShortenerUITests: XCTestCase {
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                let app = XCUIApplication()
                app.launchArguments += ["-disable-cache"]
                app.launch()
            }
        }
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-disable-cache"]
        app.launch()

        UIPasteboard.general.string = "https://www.linkedin.com/in/edyuto/"

        let textField = app.textFields["https://www.linkedin.com/in/edyuto/"].firstMatch
        textField.tap()
        textField.press(forDuration: 1.2)

        let pasteBoard = app.staticTexts["Paste"].firstMatch
        pasteBoard.tap()

        app.buttons.element(boundBy: 5).tap()
        app.staticTexts["https://url-shortener-server.onrender.com/api/alias/1544093959"].firstMatch.tap()

        let alertConfirmButton = app.buttons["Ok"].firstMatch
        alertConfirmButton.tap()

        let textFieldClearButton = app.buttons["Clear text"].firstMatch
        textFieldClearButton.tap()

        UIPasteboard.general.string = "https://github.com/EdYuTo"
        textField.press(forDuration: 0.9)
        pasteBoard.tap()

        let keyboardEnterKey = app.buttons["Return"].firstMatch
        keyboardEnterKey.tap()

        app.staticTexts["https://url-shortener-server.onrender.com/api/alias/1341138848"].firstMatch.tap()
        alertConfirmButton.tap()
        app.textFields["https://github.com/EdYuTo"].firstMatch.tap()

        textFieldClearButton.tap()
        textField.press(forDuration: 1.0)

        UIPasteboard.general.string = "https://stackoverflow.com/users/12585616/edyuto"
        pasteBoard.tap()
        keyboardEnterKey.tap()
        app.staticTexts["https://url-shortener-server.onrender.com/api/alias/1066423859"].firstMatch.tap()
        alertConfirmButton.tap()
    }
}
