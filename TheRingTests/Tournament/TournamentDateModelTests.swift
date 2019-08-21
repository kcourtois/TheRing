//
//  TournamentDateModelTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 21/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class TournamentDateModelTests: XCTestCase {
    var didSendNotif: Bool!
    var handler: ((Notification) -> Void)!
    var testExpectation: XCTestExpectation!
    var tournament: Tournament!

    override func setUp() {
        didSendNotif = false
        testExpectation = expectation(description: "Did finish operation expectation")
        handler = { (notification: Notification) -> Void in
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
        tournament = Tournament(tid: "tid", title: "test", description: "test", contestants: [],
                                startTime: Date(), roundDuration: 1, creator: "kcourtois")
    }

    func testGivenGoodDataWhenCallingCreateTournamentThenShouldSendCreateTournamentNotification() {
        let tournamentDateModel = TournamentDateModel(tournamentService: TestTournamentGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didCreateTournament,
                                                           object: nil, queue: nil, using: handler)

        tournamentDateModel.createTournament(tournament: tournament)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadDataWhenCallingCreateTournamentThenShouldSendCreateTournamentNotification() {
        let tournamentDateModel = TournamentDateModel(tournamentService: TestTournamentBadData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        tournamentDateModel.createTournament(tournament: tournament)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }
}
