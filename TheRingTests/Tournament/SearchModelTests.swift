//
//  SearchModelTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 21/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class SearchModelTests: XCTestCase {

    var didSendNotif: Bool!
    var handler: ((Notification) -> Void)!
    var testExpectation: XCTestExpectation!
    var tournaments: [TournamentData] = []

    override func setUp() {
        didSendNotif = false
        testExpectation = expectation(description: "Did finish operation expectation")
        handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: [TournamentData]] {
                for (_, tournaments) in data {
                    self.tournaments = tournaments
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
    }

    func testGivenGoodDataWhenCallingGetAllTournamentsThenShouldSendTournamentDataWithTwoItems() {
        let searchModel = SearchModel(tournamentService: TestTournamentGoodData())

        let notif = NotificationCenter.default.addObserver(forName: .didSendTournamentData,
                                                           object: nil, queue: nil, using: handler)

        searchModel.getAllTournaments()

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(tournaments.count, 2)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenGoodDataWhenCallingGetAllTournamentsWithSearchParamThenShouldSendTournamentDataWithOneItems() {
        let searchModel = SearchModel(tournamentService: TestTournamentGoodData())

        let notif = NotificationCenter.default.addObserver(forName: .didSendTournamentData,
                                                           object: nil, queue: nil, using: handler)

        searchModel.getAllTournaments(search: "test")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(tournaments.count, 1)
        NotificationCenter.default.removeObserver(notif)
    }
}
