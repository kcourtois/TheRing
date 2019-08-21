//
//  TestCommentGoodData.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 21/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class TestCommentGoodData: CommentService {
    func registerComment(tid: String, comment: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func getComments(tid: String, completion: @escaping ([Comment]) -> Void) {
        completion([Comment(cid: "cid1", uid: "uid1", username: "Kevin", comment: "Awesome"),
                    Comment(cid: "cid2", uid: "uid2", username: "Alain", comment: "I like it too")])
    }

}
