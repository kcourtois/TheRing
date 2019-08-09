//
//  CommentService.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

protocol CommentService {
    func registerComment(tid: String, comment: String, completion: @escaping (String?) -> Void)

    func getComments(tid: String, completion: @escaping ([Comment]) -> Void)
}
