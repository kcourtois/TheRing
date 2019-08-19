//
//  SignupModelTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class SignupModelTests: XCTestCase {

    var didSendNotif: Bool!
    var handler: ((Notification) -> Void)!
    var testExpectation: XCTestExpectation!

    override func setUp() {
        didSendNotif = false
        testExpectation = expectation(description: "Did finish operation expectation")
        handler = { (notification: Notification) -> Void in
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
    }

    func testGivenGoodDataWhenCallingRegisterUserThenShouldSendSignupNotification() {
        let signupModel = SignupModel(authService: TestAuthGoodData(), userService: TestUserGoodData(),
                                      preferences: Preferences(defaults: .makeClearedInstance()))

        let notif = NotificationCenter.default.addObserver(forName: .didSignUp,
                                                           object: nil, queue: nil, using: handler)

        signupModel.registerUser(email: "test@gmail.com", password: "qwerty", confirm: "qwerty", username: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenNilFieldsWhenCallingRegisterUserThenShouldSendErrorNotification() {
        let signupModel = SignupModel(authService: TestAuthGoodData(), userService: TestUserGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        signupModel.registerUser(email: nil, password: nil, confirm: nil, username: nil)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenEmptyFieldsWhenCallingRegisterUserThenShouldSendErrorNotification() {
        let signupModel = SignupModel(authService: TestAuthGoodData(), userService: TestUserGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        signupModel.registerUser(email: " ", password: " ", confirm: " ", username: " ")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenWrongConfirmFieldWhenCallingRegisterUserThenShouldSendErrorNotification() {
        let signupModel = SignupModel(authService: TestAuthGoodData(), userService: TestUserGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        signupModel.registerUser(email: "test@gmail.com", password: "qwerty", confirm: "azerty", username: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenUsernameNotAvailableWhenCallingRegisterUserThenShouldSendErrorNotification() {
        let signupModel = SignupModel(authService: TestAuthGoodData(), userService: UsernameNotAvailable())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        signupModel.registerUser(email: "test@gmail.com", password: "qwerty", confirm: "qwerty", username: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenAuthCreateUserFailedWhenCallingRegisterUserThenShouldSendErrorNotification() {
        let signupModel = SignupModel(authService: TestAuthBadData(), userService: TestUserGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        signupModel.registerUser(email: "test@gmail.com", password: "qwerty", confirm: "qwerty", username: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenAuthUIDNilButNoErrorWhenCallingRegisterUserThenShouldSendErrorNotification() {
        let signupModel = SignupModel(authService: CreateUserNilUID(), userService: TestUserGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        signupModel.registerUser(email: "test@gmail.com", password: "qwerty", confirm: "qwerty", username: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenSignupRequestWhenRegisterUserInfoErrorThenShouldSendErrorNotification() {
        let signupModel = SignupModel(authService: TestAuthGoodData(), userService: UserRegisterInfo())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        signupModel.registerUser(email: "test@gmail.com", password: "qwerty", confirm: "qwerty", username: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenSignupRequestWhenRegisterUsernameErrorThenShouldSendErrorNotification() {
        let signupModel = SignupModel(authService: TestAuthGoodData(), userService: UserRegisterUsername())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        signupModel.registerUser(email: "test@gmail.com", password: "qwerty", confirm: "qwerty", username: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }
}
