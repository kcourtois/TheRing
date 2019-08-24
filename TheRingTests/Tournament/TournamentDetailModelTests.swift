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

////Returns the winner of a given round
//func getWinner(round: Int, cids: [String], tournament: TournamentData,
//               completion: @escaping ([String]?) -> Void) {
//    var contRes = [UInt]()
//    let dispatchGroup = DispatchGroup()
//
//    //Append blank votes results for each contestant
//    for _ in 0..<cids.count {
//        contRes.append(0)
//    }
//
//    //get votes count for all contestants
//    for ind in 0..<cids.count {
//        dispatchGroup.enter()
//        voteService.getVotes(cid: cids[ind],
//                             rid: tournament.rounds[round].rid) { (res) in
//                                if let res = res {
//                                    contRes[ind] = res
//                                    dispatchGroup.leave()
//                                }
//        }
//    }
//
//    dispatchGroup.notify(queue: .main) {
//        var result = [String]()
//        //check winner of each duel
//        for index in stride(from: 0, to: cids.count-1, by: 2) {
//            if contRes[index] >= contRes[index+1] {
//                result.append(cids[index])
//            } else {
//                result.append(cids[index+1])
//            }
//        }
//        completion(result)
//    }
//}

////vote for the tapped contestant if possible
//func contestantTapped(uid: String, tag: Int, tournament: TournamentData) {
//    let round = getCurrentRoundIndex(rounds: tournament.rounds)
//    switch round {
//    //if first round and image tapped < 4, vote
//    case 0:
//        if tag < 4 {
//            postLoadVoteNotification(tag: tag)
//            registerVote(uid: uid, rid: tournament.rounds[round].rid, cid: tournament.contestants[tag].cid)
//        }
//    //if second round and image tapped > 3 and < 6, vote
//    case 1:
//        if tag > 3 && tag < 6 && tournament.rounds[round].endDate > Date() {
//            postLoadVoteNotification(tag: tag)
//            getWinner(round: 0, cids: tournament.getCids(),
//                      tournament: tournament) { (res) in
//                        if let cid = res {
//                            self.registerVote(uid: uid, rid: tournament.rounds[round].rid, cid: cid[tag-4])
//                        }
//            }
//        }
//    default:
//        break
//    }
//}
//

//
////get user votes for round 1 & 2
//func getUserVotes(uid: String, tournament: TournamentData) {
//    //get vote for round 1
//    voteService.getUserVote(uid: uid, rid: tournament.rounds[0].rid) { (cid) in
//        if let cid = cid {
//            for (index, cont) in tournament.contestants.enumerated() where cid == cont.cid {
//                self.postLoadVoteNotification(tag: index)
//            }
//        }
//    }
//    //get vote for round 2
//    voteService.getUserVote(uid: uid, rid: tournament.rounds[1].rid) { (cid) in
//        if let cid = cid {
//            switch cid {
//            case tournament.contestants[0].cid, tournament.contestants[1].cid:
//                self.postLoadVoteNotification(tag: 4)
//            case tournament.contestants[2].cid, tournament.contestants[3].cid:
//                self.postLoadVoteNotification(tag: 5)
//            default:
//                break
//            }
//        }
//    }
//}
