//
//  TestTournamentBadData.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 14/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class TestTournamentBadData: TournamentService {
    func createTournament(tournament: Tournament, completion: @escaping (String?) -> Void) {

    }

    func getUserTournamentsWithData(completion: @escaping ([TournamentData]) -> Void) {
        completion([])
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
