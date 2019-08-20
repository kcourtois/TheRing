//
//  CommentModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class CommentModel {
    private let commentService: CommentService

    init(commentService: CommentService) {
        self.commentService = commentService
    }

    //get comments for given tid
    func getComments(tid: String) {
        commentService.getComments(tid: tid, completion: { (result) in
            self.postDidSendCommentsNotification(comments: result)
        })
    }

    //register comment for given tid
    func registerComment(tid: String, comment: String) {
        commentService.registerComment(tid: tid, comment: comment) { (error) in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.postDidRegisterCommentNotification()
            }
        }
    }

    //register comment notification
    private func postDidRegisterCommentNotification() {
        NotificationCenter.default.post(name: .didRegisterComment, object: nil,
                                        userInfo: [NotificationStrings.didRegisterCommentKey:
                                                   NotificationStrings.didRegisterCommentKey])
    }

    //send comment notification
    private func postDidSendCommentsNotification(comments: [Comment]) {
        NotificationCenter.default.post(name: .didSendComments, object: nil,
                                        userInfo: [NotificationStrings.didSendCommentsKey: comments])
    }

    //send error notification
    private func postErrorNotification(error: String) {
        NotificationCenter.default.post(name: .didSendError, object: nil,
                                        userInfo: [NotificationStrings.didSendErrorKey: error])
    }
}
