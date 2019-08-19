//
//  EmailModelTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 19/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class EmailModelTests: XCTestCase {
    var didSendNotif: Bool!
    var handler: ((Notification) -> Void)!
    var testExpectation: XCTestExpectation!
    var preferences: Preferences!
    var error: String = ""

    override func setUp() {
        preferences = Preferences(defaults: .makeClearedInstance())
        didSendNotif = false
        testExpectation = expectation(description: "Did finish operation expectation")
        handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: String] {
                for (_, errorStr) in data {
                    self.error = errorStr
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
    }

    func testGivenGoodDataWhenCallingUpdateEmailThenShouldSendRegisterNotification() {
        let emailModel = EmailModel(authService: TestAuthGoodData(), userService: TestUserGoodData(),
                                    preferences: preferences)
        let notif = NotificationCenter.default.addObserver(forName: .didRegisterUserInfo,
                                                           object: nil, queue: nil, using: handler)

        emailModel.updateEmail(password: "pass", mail: "mail", confirm: "mail")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenEmptyFieldsWhenCallingUpdateEmailThenShouldSendErrorNotification() {
        let emailModel = EmailModel(authService: TestAuthGoodData(), userService: TestUserGoodData(),
                                    preferences: preferences)
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        emailModel.updateEmail(password: " ", mail: " ", confirm: " ")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(error, TRStrings.emptyFields.localizedString)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenSameEmailWhenCallingUpdateEmailThenShouldSendErrorNotification() {
        let emailModel = EmailModel(authService: TestAuthGoodData(), userService: TestUserGoodData(),
                                    preferences: preferences)
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)
        preferences.user = TRUser(uid: "uid", name: "test", gender: .other, email: "test@gmail.com", bio: "bio")

        emailModel.updateEmail(password: "test", mail: "test@gmail.com", confirm: "test@gmail.com")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(error, TRStrings.mailSelfUse.localizedString)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenWrongConfirmWhenCallingUpdateEmailThenShouldSendErrorNotification() {
        let emailModel = EmailModel(authService: TestAuthGoodData(), userService: TestUserGoodData(),
                                    preferences: preferences)
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        emailModel.updateEmail(password: "test", mail: "test@gmail.com", confirm: "test2@gmail.com")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(error, TRStrings.confirmWrong.localizedString)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadAuthWhenCallingUpdateEmailThenShouldSendErrorNotification() {
        let emailModel = EmailModel(authService: TestAuthBadData(), userService: TestUserGoodData(),
                                    preferences: preferences)
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        emailModel.updateEmail(password: "test", mail: "test@gmail.com", confirm: "test2@gmail.com")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadUserWhenCallingUpdateEmailThenShouldSendErrorNotification() {
        let emailModel = EmailModel(authService: TestAuthGoodData(), userService: TestUserBadData(),
                                    preferences: preferences)
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        emailModel.updateEmail(password: "test", mail: "test@gmail.com", confirm: "test2@gmail.com")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }
}
