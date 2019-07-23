//
//  TournamentData.swift
//  TheRing
//
//  Created by Kévin Courtois on 20/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

struct TournamentData {
    let tid: String
    let title: String
    let description: String
    let creator: TRUser
    let startTime: Date
    var rounds: [Round]
}

struct Round {
    let rid: String
    let endDate: Date
    var matches: [Match]
}

struct Match {
    let mid: String
    let contestant1: Contestant
    let contestant2: Contestant
}

struct Contestant {
    let cid: String
    let image: String
    let name: String
}
