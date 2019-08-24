//
//  TestFailRegisterVote.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 24/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class TestFailRegisterVote: VoteService {
    func registerVote(rid: String, uid: String, cid: String, completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    func getUserVote(uid: String, rid: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func getVotes(cid: String, rid: String, completion: @escaping (UInt?) -> Void) {
        switch cid {
        case "cid0":
            completion(2)
        case "cid1":
            completion(5)
        case "cid2":
            completion(8)
        case "cid3":
            completion(3)
        default:
            completion(0)
        }
    }

    func removeUserVote(uid: String, rid: String, cid: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }
}
