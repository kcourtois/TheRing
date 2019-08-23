//
//  TournamentDetailModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

//model for tournament detail controller
class TournamentDetailModel {
    private let tournamentService: TournamentService
    private let voteService: VoteService

    init(tournamentService: TournamentService, voteService: VoteService) {
        self.tournamentService = tournamentService
        self.voteService = voteService
    }

    //return current round index
    func getCurrentRoundIndex(rounds: [Round]) -> Int {
        for (index, round) in rounds.enumerated() {
            if Date() < round.endDate {
                return index
            }
        }
        return rounds.count-1
    }

    //Returns the winner of a given round
    func getWinner(round: Int, cids: [String], tournament: TournamentData,
                   completion: @escaping ([String]?) -> Void) {
        var contRes = [UInt]()
        let dispatchGroup = DispatchGroup()

        //Append blank votes results for each contestant
        for _ in 0..<cids.count {
            contRes.append(0)
        }

        //get votes count for all contestants
        for ind in 0..<cids.count {
            dispatchGroup.enter()
            voteService.getVotes(cid: cids[ind],
                                 rid: tournament.rounds[round].rid) { (res) in
                if let res = res {
                    contRes[ind] = res
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            var result = [String]()
            //check winner of each duel
            for index in stride(from: 0, to: cids.count-1, by: 2) {
                if contRes[index] >= contRes[index+1] {
                    result.append(cids[index])
                } else {
                    result.append(cids[index+1])
                }
            }
            completion(result)
        }
    }

    //vote for the tapped contestant if possible
    func contestantTapped(uid: String, tag: Int, tournament: TournamentData) {
        let round = getCurrentRoundIndex(rounds: tournament.rounds)
        switch round {
        //if first round and image tapped < 4, vote
        case 0:
            if tag < 4 {
                postLoadVoteNotification(tag: tag)
                registerVote(uid: uid, rid: tournament.rounds[round].rid, cid: tournament.contestants[tag].cid)
            }
        //if second round and image tapped > 3 and < 6, vote
        case 1:
            if tag > 3 && tag < 6 && tournament.rounds[round].endDate > Date() {
                postLoadVoteNotification(tag: tag)
                getWinner(round: 0, cids: tournament.getCids(),
                          tournament: tournament) { (res) in
                    if let cid = res {
                        self.registerVote(uid: uid, rid: tournament.rounds[round].rid, cid: cid[tag-4])
                    }
                }
            }
        default:
            break
        }
    }

    //load UI for stages of the tournament, showing winner of rounds etc.
    func loadStages(tournament: TournamentData) {
        let round = getCurrentRoundIndex(rounds: tournament.rounds)
        if round > 0 {
            getWinner(round: round-1, cids: tournament.getCids(), tournament: tournament) { (result) in
                if let cids = result {
                    self.postSetFirstStageNotification(cids: cids)
                    if tournament.rounds[round].endDate < Date() {
                        self.getWinner(round: round, cids: cids, tournament: tournament) { (result) in
                            if let res = result {
                                self.postSetSecondStageNotification(cids: res)
                            }
                        }
                    }
                } else {
                    self.postErrorNotification(error: TRStrings.errorOccured.localizedString)
                }
            }
        }
    }

    //get user votes for round 1 & 2
    func getUserVotes(uid: String, tournament: TournamentData) {
        //get vote for round 1
        voteService.getUserVote(uid: uid, rid: tournament.rounds[0].rid) { (cid) in
            if let cid = cid {
                for (index, cont) in tournament.contestants.enumerated() where cid == cont.cid {
                    self.postLoadVoteNotification(tag: index)
                }
            }
        }
        //get vote for round 2
        voteService.getUserVote(uid: uid, rid: tournament.rounds[1].rid) { (cid) in
            if let cid = cid {
                switch cid {
                case tournament.contestants[0].cid, tournament.contestants[1].cid:
                    self.postLoadVoteNotification(tag: 4)
                case tournament.contestants[2].cid, tournament.contestants[3].cid:
                    self.postLoadVoteNotification(tag: 5)
                default:
                    break
                }
            }
        }
    }

    //get current user vote for given uid/rid
    private func registerVote(uid: String, rid: String, cid: String) {
        voteService.getUserVote(uid: uid, rid: rid) { (result) in
            if let contId = result {
                //remove previous cid
                self.removeUserVote(uid: uid, rid: rid, cid: contId)
            }
            self.voteService.registerVote(rid: rid, uid: uid, cid: cid) { (error) in
                if let error = error {
                    self.postErrorNotification(error: error)
                }
            }
        }
    }

    //remove user vote for given parameters
    private func removeUserVote(uid: String, rid: String, cid: String) {
        voteService.removeUserVote(uid: uid, rid: rid, cid: cid) { (error) in
            if let error = error {
                self.postErrorNotification(error: error)
            }
        }
    }

    //load vote notification
    private func postLoadVoteNotification(tag: Int) {
        NotificationCenter.default.post(name: .didLoadVote, object: nil,
                                        userInfo: [NotificationStrings.didLoadVoteKey: tag])
    }

    //send set first stage notification
    private func postSetFirstStageNotification(cids: [String]) {
        NotificationCenter.default.post(name: .didSendSetFirstStage, object: nil,
                                        userInfo: [NotificationStrings.didSendSetFirstStageKey: cids])
    }

    //send set second stage notification
    private func postSetSecondStageNotification(cids: [String]) {
        NotificationCenter.default.post(name: .didSendSetSecondStage, object: nil,
                                        userInfo: [NotificationStrings.didSendSetSecondStageKey: cids])
    }

    //send error notification
    private func postErrorNotification(error: String) {
        NotificationCenter.default.post(name: .didSendError, object: nil,
                                        userInfo: [NotificationStrings.didSendErrorKey: error])
    }
}
