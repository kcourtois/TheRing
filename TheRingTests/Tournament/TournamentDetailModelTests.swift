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

//    func testGivenBadDataWhenCallingRemoveUserVoteThenShouldSendErrorNotification() {
//        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
//                                                          voteService: TestVoteBadData())
//        let notif = NotificationCenter.default.addObserver(forName: .didSendComments,
//                                                           object: nil, queue: nil, using: handler)
//
//        //tournamentDetailModel.removeUserVote()
//
//        waitForExpectations(timeout: 1, handler: nil)
//        XCTAssertTrue(didSendNotif)
//        NotificationCenter.default.removeObserver(notif)
//    }

    func testGivenDateBeforeRoundsEndWhenCallingGetCurrentRoundIndexThenShouldReturnZero() {
        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
                                                          voteService: TestVoteBadData())

        let firstEndDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let secondEndDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        let rounds: [Round] = [Round(rid: "round1", endDate: firstEndDate),
                               Round(rid: "round2", endDate: secondEndDate)]

        let index = tournamentDetailModel.getCurrentRoundIndex(rounds: rounds)

        testExpectation.fulfill()
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(index, 0)
    }

    func testGivenDateBetweenRoundsEndWhenCallingGetCurrentRoundIndexThenShouldReturnOne() {
        let tournamentDetailModel = TournamentDetailModel(tournamentService: TestTournamentGoodData(),
                                                          voteService: TestVoteBadData())

        let firstEndDate = Date()
        let secondEndDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let rounds: [Round] = [Round(rid: "round1", endDate: firstEndDate),
                               Round(rid: "round2", endDate: secondEndDate)]

        let index = tournamentDetailModel.getCurrentRoundIndex(rounds: rounds)

        testExpectation.fulfill()
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(index, 1)
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
//
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
////load UI for stages of the tournament, showing winner of rounds etc.
//func loadStages(tournament: TournamentData) {
//    let round = getCurrentRoundIndex(rounds: tournament.rounds)
//    if round > 0 {
//        getWinner(round: round-1, cids: tournament.getCids(), tournament: tournament) { (result) in
//            if let cids = result {
//                self.postSetFirstStageNotification(cids: cids)
//                if tournament.rounds[round].endDate < Date() {
//                    self.getWinner(round: round, cids: cids, tournament: tournament) { (result) in
//                        if let res = result {
//                            self.postSetSecondStageNotification(cids: res)
//                        }
//                    }
//                }
//            } else {
//                self.postErrorNotification(error: TRStrings.errorOccured.localizedString)
//            }
//        }
//    }
//}
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
