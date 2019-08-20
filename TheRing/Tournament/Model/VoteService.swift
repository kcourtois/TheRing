//
//  VoteService.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

protocol VoteService {
    func registerVote(rid: String, uid: String, cid: String, completion: @escaping (String?) -> Void)

    func getUserVote(uid: String, rid: String, completion: @escaping (String?) -> Void)

    func getVotes(cid: String, rid: String, completion: @escaping (UInt?) -> Void)

    func removeUserVote(uid: String, rid: String, cid: String, completion: @escaping (String?) -> Void)
}
