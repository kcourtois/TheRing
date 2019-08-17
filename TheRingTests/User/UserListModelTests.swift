//
//  UserListModelTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 17/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class UserListModelTests: XCTestCase {
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

    func testGivenGoodDataWhenCallingGetUserInfoThenShouldReturnTRUser() {
        let userListModel = UserListModel(userService: TestUserGoodData())
        var userInfo: TRUser?
        handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: TRUser] {
                for (_, user) in data {
                    userInfo = user
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSendUserInfo,
                                                           object: nil, queue: nil, using: handler)

        userListModel.getUserInfo(uid: "uid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertNotNil(userInfo)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadDataWhenCallingGetUserInfoThenShouldSendError() {
        let userListModel = UserListModel(userService: TestUserBadData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        userListModel.getUserInfo(uid: "uid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenSubscribersTypeListWhenCallingGetSubsThenShouldReturnTwoUsers() {
        let userListModel = UserListModel(userService: TestUserGoodData())
        var userInfo: [TRUser] = []
        handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: [TRUser]] {
                for (_, users) in data {
                    userInfo = users
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSendSubs,
                                                           object: nil, queue: nil, using: handler)

        userListModel.getSubs(userType: .subscribers)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(userInfo.count, 2)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenSubscriptionsTypeListWhenCallingGetSubsThenShouldReturnThreeUsers() {
        let userListModel = UserListModel(userService: TestUserGoodData())
        var userInfo: [TRUser] = []
        handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: [TRUser]] {
                for (_, users) in data {
                    userInfo = users
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSendSubs,
                                                           object: nil, queue: nil, using: handler)

        userListModel.getSubs(userType: .subscriptions)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(userInfo.count, 3)
        NotificationCenter.default.removeObserver(notif)
    }
}
