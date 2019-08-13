//
//  LoginTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class LoginModelTests: XCTestCase {

    func testGivenUserLoggedWhenCallingAlreadyLoggedThenShouldBeTrue() {
        let loginModel = LoginModel(authService: TestAuthGoodData())

        XCTAssertTrue(loginModel.alearyLogged())
    }

    func testGivenUserNotLoggedWhenCallingAlreadyLoggedThenShouldBeFalse() {
        let loginModel = LoginModel(authService: TestAuthBadData())

        XCTAssertFalse(loginModel.alearyLogged())
    }

    func testGivenValidCredentialsWhenCallingSignInThenShouldSendSignInNotification() {
        let loginModel = LoginModel(authService: TestAuthGoodData())
        var didSendNotif = false
        let testExpectation = expectation(description: "Did finish operation expectation")
        let handler = { (notification: Notification) -> Void in
            didSendNotif = true
            testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSignIn,
                                                           object: nil, queue: nil, using: handler)

        loginModel.signIn(email: "test", password: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenInvalidCredentialsWhenCallingSignInThenShouldSendErrorNotification() {
        let loginModel = LoginModel(authService: TestAuthBadData())
        var didSendNotif = false
        let testExpectation = expectation(description: "Did finish operation expectation")
        let handler = { (notification: Notification) -> Void in
            didSendNotif = true
            testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        loginModel.signIn(email: "test", password: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }
}


//Preferences().user = TRUser(uid: uid, name: username, gender: .other, email: email, bio: "")
//
////register user data in firebase database
//private func registerUserInfo(uid: String, username: String, values: [String: Any]) {
//    userService.registerUserInfo(uid: uid, values: values) { error in
//        if let error = error {
//            self.postErrorNotification(error: error)
//        } else {
//            self.registerUsername(username: username, uid: uid)
//        }
//    }
//}
//
////register username, which is used when checking if username is available
//private func registerUsername(username: String, uid: String) {
//    userService.registerUsername(name: username, uid: uid) { error in
//        if let error = error {
//            self.postErrorNotification(error: error)
//        } else {
//            self.postSignUpNotification()
//        }
//    }
//}
