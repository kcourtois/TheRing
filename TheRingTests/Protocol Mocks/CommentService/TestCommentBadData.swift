//
//  TestCommentBadData.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 21/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class TestCommentBadData: CommentService {
    func registerComment(tid: String, comment: String, completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    func getComments(tid: String, completion: @escaping ([Comment]) -> Void) {
        completion([])
    }

}
