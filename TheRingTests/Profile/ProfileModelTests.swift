//
//  ProfileModelTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 19/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class ProfileModelTests: XCTestCase {
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

    func testGivenAvailableUsernameWhenCallingCheckUsernameAndSaveThenShouldSendSaveNotification() {
        let profileModel = ProfileModel(userService: TestUserGoodData(),
                                        preferences: Preferences(defaults: .makeClearedInstance()))

        let notif = NotificationCenter.default.addObserver(forName: .didSendSaveUser,
                                                           object: nil, queue: nil, using: handler)

        profileModel.checkUsernameAndSave(name: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenUnavailableUsernameWhenCallingCheckUsernameAndSaveThenShouldSendErrorNotification() {
        let profileModel = ProfileModel(userService: TestUserBadData(),
                                        preferences: Preferences(defaults: .makeClearedInstance()))
        var error = ""
        self.handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: String] {
                for (_, errorStr) in data {
                    error = errorStr
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        profileModel.checkUsernameAndSave(name: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(error, TRStrings.usernameUsed.localizedString)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadDataWhenCallingCheckUsernameAndSaveThenShouldSendErrorNotification() {
        let profileModel = ProfileModel(userService: UserRegisterUsername(),
                                        preferences: Preferences(defaults: .makeClearedInstance()))
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        profileModel.checkUsernameAndSave(name: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenGoodDataWhenCallingRegisterUserInfoThenShouldSendRegisterUserInfoNotification() {
        let profileModel = ProfileModel(userService: TestUserGoodData(),
                                        preferences: Preferences(defaults: .makeClearedInstance()))
        let notif = NotificationCenter.default.addObserver(forName: .didRegisterUserInfo,
                                                           object: nil, queue: nil, using: handler)

        profileModel.registerUserInfo(values: [:])

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadDataWhenCallingRegisterUserInfoThenShouldSendErrorNotification() {
        let profileModel = ProfileModel(userService: TestUserBadData(),
                                        preferences: Preferences(defaults: .makeClearedInstance()))
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        profileModel.registerUserInfo(values: [:])

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }
}
