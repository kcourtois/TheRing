//
//  PasswordModelTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 19/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class PasswordModelTests: XCTestCase {
    var didSendNotif: Bool!
    var handler: ((Notification) -> Void)!
    var testExpectation: XCTestExpectation!
    var error: String = ""

    override func setUp() {
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

    func testGivenGoodDataWhenCallingPasswordUpdateThenShouldSendUpdatePasswordNotification() {
        let passwordModel = PasswordModel(authService: TestAuthGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didUpdatePassword,
                                                           object: nil, queue: nil, using: handler)

        passwordModel.updatePassword(oldPwd: "test1", newPwd: "test2", confirm: "test2")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenFieldsEmptyWhenCallingPasswordUpdateThenShouldSendErrorNotification() {
        let passwordModel = PasswordModel(authService: TestAuthGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        passwordModel.updatePassword(oldPwd: " ", newPwd: " ", confirm: " ")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(error, TRStrings.emptyFields.localizedString)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenConfirmWrongWhenCallingPasswordUpdateThenShouldSendErrorNotification() {
        let passwordModel = PasswordModel(authService: TestAuthGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        passwordModel.updatePassword(oldPwd: "test", newPwd: "test2", confirm: "test3")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(error, TRStrings.confirmWrong.localizedString)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadDataWhenCallingPasswordUpdateThenShouldSendErrorNotification() {
        let passwordModel = PasswordModel(authService: TestAuthBadData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        passwordModel.updatePassword(oldPwd: "test", newPwd: "test2", confirm: "test2")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(error, TRStrings.errorOccured.localizedString)
        NotificationCenter.default.removeObserver(notif)
    }
}
