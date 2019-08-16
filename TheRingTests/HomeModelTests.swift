//
//  HomeModelTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 14/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class HomeModelTests: XCTestCase {

    var didSendNotif: Bool!
    var handler: ((Notification) -> Void)!
    var testExpectation: XCTestExpectation!
    var itemCount: Int = 0

    override func setUp() {
        didSendNotif = false
        testExpectation = expectation(description: "Did finish operation expectation")
        handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: [TournamentData]] {
                for (_, tournaments) in data {
                    self.itemCount = tournaments.count
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
    }

    func testGivenGoodDataWhenCallingGetUserTournamentsThenShouldSendTournamentDataWithTwoItems() {
        let homeModel = HomeModel(authService: TestAuthGoodData(), userService: TestUserGoodData(),
                                  tournamentService: TestTournamentGoodData(),
                                  preferences: Preferences(defaults: .makeClearedInstance()))

        let notif = NotificationCenter.default.addObserver(forName: .didSendTournamentData,
                                                           object: nil, queue: nil, using: handler)

        homeModel.getUserTournaments()

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(itemCount, 2)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenGoodDataWhenCallingGetUserTournamentsThenShouldSendTournamentDataEmpty() {
        let homeModel = HomeModel(authService: TestAuthGoodData(), userService: TestUserGoodData(),
                                  tournamentService: TestTournamentBadData(),
                                  preferences: Preferences(defaults: .makeClearedInstance()))

        let notif = NotificationCenter.default.addObserver(forName: .didSendTournamentData,
                                                           object: nil, queue: nil, using: handler)

        homeModel.getUserTournaments()

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(itemCount, 0)
        NotificationCenter.default.removeObserver(notif)
    }
}
