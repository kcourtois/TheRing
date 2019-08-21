//
//  TestVoteGoodData.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 21/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class TestVoteGoodData: VoteService {
    func registerVote(rid: String, uid: String, cid: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func getUserVote(uid: String, rid: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func getVotes(cid: String, rid: String, completion: @escaping (UInt?) -> Void) {
        completion(2)
    }

    func removeUserVote(uid: String, rid: String, cid: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }
}
