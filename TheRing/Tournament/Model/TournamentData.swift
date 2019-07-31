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
    var contestants: [Contestant]

    func getCids() -> [String] {
        var cids = [String]()
        for cont in contestants {
            cids.append(cont.cid)
        }
        return cids
    }
}

struct Round {
    let rid: String
    let endDate: Date
}

struct Contestant {
    let cid: String
    let image: String
    let name: String
}

struct Comment {
    let cid: String
    let uid: String
    let username: String
    let comment: String
}
