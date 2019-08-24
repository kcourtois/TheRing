//
//  TournamentDetailModelTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 21/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class TournamentDetailModelTests: XCTestCase {
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

    func testGivenDateBeforeRoundsEndWhenCallingGetCurrentRoundIndexThenShouldReturnZero() {
        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
                                                          voteService: TestVoteBadData())

        let index = tournamentDetailModel.getCurrentRoundIndex(rounds: getFakeRounds(addFirst: 1, addSecond: 2))

        testExpectation.fulfill()
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(index, 0)
    }

    func testGivenDateBetweenRoundsEndWhenCallingGetCurrentRoundIndexThenShouldReturnOne() {
        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
                                                          voteService: TestVoteBadData())

        let index = tournamentDetailModel.getCurrentRoundIndex(rounds: getFakeRounds(addFirst: 0, addSecond: 1))

        testExpectation.fulfill()
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(index, 1)
    }

    func testGivenTournamentInFirstRoundWhenCallingLoadStagesShouldThenShouldSendFirstStageNotification() {
        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
                                                          voteService: TestVoteGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendSetFirstStage,
                                                           object: nil, queue: nil, using: handler)
        let tournament = TournamentData(tid: "tid", title: "title", description: "desc",
                                        creator: getFakeUser(), startTime: Date(),
                                        rounds: getFakeRounds(addFirst: -1, addSecond: 2),
                                        contestants: getFakeContestants())

        tournamentDetailModel.loadStages(tournament: tournament)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenTournamentInSecondRoundWhenCallingLoadStagesShouldThenShouldSendSecondStageNotification() {
        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
                                                          voteService: TestVoteGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendSetSecondStage,
                                                           object: nil, queue: nil, using: handler)
        let tournament = TournamentData(tid: "tid", title: "title", description: "desc",
                                        creator: getFakeUser(), startTime: Date(),
                                        rounds: getFakeRounds(addFirst: -1, addSecond: -2),
                                        contestants: getFakeContestants())

        tournamentDetailModel.loadStages(tournament: tournament)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenTournamentFirstRoundWhenCallingContestantTappedThenShouldSendLoadVoteNotification() {
        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
                                                          voteService: TestVoteGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didLoadVote,
                                                           object: nil, queue: nil, using: handler)
        let tournament = TournamentData(tid: "tid", title: "title", description: "desc",
                                        creator: getFakeUser(), startTime: Date(),
                                        rounds: getFakeRounds(addFirst: 1, addSecond: 2),
                                        contestants: getFakeContestants())

        tournamentDetailModel.contestantTapped(uid: "uid", tag: 0, tournament: tournament)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenTournamentSecondRoundWhenCallingContestantTappedThenShouldSendLoadVoteNotification() {
        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
                                                          voteService: TestVoteGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didLoadVote,
                                                           object: nil, queue: nil, using: handler)
        let tournament = TournamentData(tid: "tid", title: "title", description: "desc",
                                        creator: getFakeUser(), startTime: Date(),
                                        rounds: getFakeRounds(addFirst: -1, addSecond: 2),
                                        contestants: getFakeContestants())

        tournamentDetailModel.contestantTapped(uid: "uid", tag: 4, tournament: tournament)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadDataWhenCallingContestantTappedThenShouldSendErrorNotification() {
        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
                                                          voteService: TestFailRegisterVote())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)
        let tournament = TournamentData(tid: "tid", title: "title", description: "desc",
                                        creator: getFakeUser(), startTime: Date(),
                                        rounds: getFakeRounds(addFirst: -1, addSecond: 2),
                                        contestants: getFakeContestants())

        tournamentDetailModel.contestantTapped(uid: "uid", tag: 4, tournament: tournament)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenRemoveVoteBugWhenCallingContestantTappedThenShouldSendErrorNotification() {
        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
                                                          voteService: TestFailRemoveVote())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)
        let tournament = TournamentData(tid: "tid", title: "title", description: "desc",
                                        creator: getFakeUser(), startTime: Date(),
                                        rounds: getFakeRounds(addFirst: -1, addSecond: 2),
                                        contestants: getFakeContestants())

        tournamentDetailModel.contestantTapped(uid: "uid", tag: 4, tournament: tournament)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenGoodDataWhenCallingGetUserVotesThenShouldSendLoadVoteNotification() {
        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
                                                          voteService: TestVoteGoodData())
        handler = { (notification: Notification) -> Void in
            if !self.didSendNotif {
                self.didSendNotif = true
                self.testExpectation.fulfill()
            }
        }
        let notif = NotificationCenter.default.addObserver(forName: .didLoadVote,
                                                           object: nil, queue: nil, using: handler)
        let tournament = TournamentData(tid: "tid", title: "title", description: "desc",
                                        creator: getFakeUser(), startTime: Date(),
                                        rounds: getFakeRounds(addFirst: -1, addSecond: 2),
                                        contestants: getFakeContestants())

        tournamentDetailModel.getUserVotes(uid: "uid", tournament: tournament)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    //creates a TRUser with fake data
    private func getFakeUser() -> TRUser {
        return TRUser(uid: "uid", name: "test", gender: .other, email: "email", bio: "bio")
    }

    //creates two rounds with fake data
    private func getFakeRounds(addFirst: Int, addSecond: Int) -> [Round] {
        let firstEndDate = Calendar.current.date(byAdding: .day, value: addFirst, to: Date())!
        let secondEndDate = Calendar.current.date(byAdding: .day, value: addSecond, to: Date())!
        let rounds: [Round] = [Round(rid: "round1", endDate: firstEndDate),
                               Round(rid: "round2", endDate: secondEndDate)]
        return rounds
    }

    //create four contestants with fake data
    private func getFakeContestants() -> [Contestant] {
        return [Contestant(cid: "cid0", image: "image0", name: "name0"),
                Contestant(cid: "cid1", image: "image1", name: "name1"),
                Contestant(cid: "cid2", image: "image2", name: "name2"),
                Contestant(cid: "cid3", image: "image3", name: "name3")]
    }
}
