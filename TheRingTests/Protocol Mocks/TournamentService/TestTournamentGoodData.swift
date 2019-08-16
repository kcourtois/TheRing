//
//  TestTournamentGoodData.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 14/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class TestTournamentGoodData: TournamentService {
    func createTournament(tournament: Tournament, completion: @escaping (String?) -> Void) {

    }

    func getUserTournamentsWithData(completion: @escaping ([TournamentData]) -> Void) {
        completion([TournamentData(tid: "tid1", title: "title1", description: "description1",
                                   creator: TRUser(uid: "uid1", name: "name1", gender: .other,
                                                   email: "email1", bio: "bio1"),
                                   startTime: Date(), rounds: [Round(rid: "rid1", endDate: Date()),
                                                               Round(rid: "rid2", endDate: Date())],
                                   contestants: [Contestant(cid: "cid1", image: "img1", name: "nameCont1"),
                                                 Contestant(cid: "cid2", image: "img2", name: "nameCont2"),
                                                 Contestant(cid: "cid3", image: "img3", name: "nameCont3"),
                                                 Contestant(cid: "cid4", image: "img4", name: "nameCont4")]),
                    TournamentData(tid: "tid2", title: "title2", description: "description2",
                                   creator: TRUser(uid: "uid2", name: "name2", gender: .other,
                                                   email: "email2", bio: "bio2"),
                                   startTime: Date(), rounds: [Round(rid: "rid3", endDate: Date()),
                                                               Round(rid: "rid4", endDate: Date())],
                                   contestants: [Contestant(cid: "cid5", image: "img5", name: "nameCont5"),
                                                 Contestant(cid: "cid6", image: "img6", name: "nameCont6"),
                                                 Contestant(cid: "cid7", image: "img7", name: "nameCont7"),
                                                 Contestant(cid: "cid8", image: "img8", name: "nameCont8")])
            ])
    }

    func getAllTournaments(completion: @escaping ([TournamentData]) -> Void) {

    }

    func getTournament(tid: String, completion: @escaping (Tournament?) -> Void) {

    }

    func getTournamentFull(tid: String, completion: @escaping (TournamentData?) -> Void) {

    }

    func getRounds(tid: String, completion: @escaping ([Round]) -> Void) {

    }

    func getContestant(tid: String, cid: String, completion: @escaping (Contestant?) -> Void) {

    }

    func getContestants(tid: String, completion: @escaping ([Contestant]) -> Void) {

    }

    func getCurrentRoundIndex(rounds: [Round]) -> Int {
        return 0
    }
}
