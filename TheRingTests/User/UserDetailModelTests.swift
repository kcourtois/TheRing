//
//  UserDetailModelTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 17/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class UserDetailModelTests: XCTestCase {
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

    func testGivenGoodDataWhenCallingGetSubscriptionsCountThenShouldReturnThree() {
        let userDetailModel = UserDetailModel(userService: TestUserGoodData())
        var count: UInt = 0
        var notifName: String = ""
        handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: UInt] {
                for (index, num) in data {
                    count = num
                    notifName = index
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSendCount,
                                                           object: nil, queue: nil, using: handler)

        userDetailModel.getSubscriptionsCount(uid: "uid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(count, 3)
        XCTAssertEqual(notifName, NotificationStrings.didSendSubscriptionsCountKey)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenGoodDataWhenCallingGetSubscribersCountThenShouldReturnFive() {
        let userDetailModel = UserDetailModel(userService: TestUserGoodData())
        var count: UInt = 0
        var notifName: String = ""
        handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: UInt] {
                for (index, num) in data {
                    count = num
                    notifName = index
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSendCount,
                                                           object: nil, queue: nil, using: handler)

        userDetailModel.getSubscribersCount(uid: "uid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(count, 5)
        XCTAssertEqual(notifName, NotificationStrings.didSendSubscribersCountKey)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadDataWhenCallingGetSubscriptionsCountThenShouldSendError() {
        let userDetailModel = UserDetailModel(userService: TestUserBadData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        userDetailModel.getSubscriptionsCount(uid: "uid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadDataWhenCallingGetSubscribersCountThenShouldSendError() {
        let userDetailModel = UserDetailModel(userService: TestUserBadData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        userDetailModel.getSubscribersCount(uid: "uid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenUIDWhenCallingUserSubbedToUIDThenShouldSendSubbedNotification() {
        let userDetailModel = UserDetailModel(userService: TestUserGoodData())
        var subbed: Bool = false
        handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: Bool] {
                for (_, isSubbed) in data {
                    subbed = isSubbed
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSendIsUserSubbed,
                                                           object: nil, queue: nil, using: handler)

        userDetailModel.userSubbedToUid(uid: "uid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertTrue(subbed)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenUIDWhenCallingSubToUserThenShouldSendSubbedNotification() {
        let userDetailModel = UserDetailModel(userService: TestUserGoodData())
        var subbed = ""
        handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: String] {
                for (_, sub) in data {
                    subbed = sub
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSendSub,
                                                           object: nil, queue: nil, using: handler)

        userDetailModel.subToUser(uid: "uid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(subbed, NotificationStrings.didSubKey)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenUIDWhenCallingUnsubToUserThenShouldSendSubbedNotification() {
        let userDetailModel = UserDetailModel(userService: TestUserGoodData())
        var subbed = ""
        let handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: String] {
                for (_, sub) in data {
                    subbed = sub
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSendSub,
                                                           object: nil, queue: nil, using: handler)

        userDetailModel.unsubToUser(uid: "uid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(subbed, NotificationStrings.didUnsubKey)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadDataWhenCallingSubToUserThenShouldSendErrorNotification() {
        let userDetailModel = UserDetailModel(userService: TestUserBadData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        userDetailModel.subToUser(uid: "uid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadDataWhenCallingUnsubToUserThenShouldSendErrorNotification() {
        let userDetailModel = UserDetailModel(userService: TestUserBadData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        userDetailModel.unsubToUser(uid: "uid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }
}
