//
//  CommentModelTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 21/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class CommentModelTests: XCTestCase {
    var didSendNotif: Bool!
    var handler: ((Notification) -> Void)!
    var testExpectation: XCTestExpectation!

    override func setUp() {
        didSendNotif = false
        testExpectation = expectation(description: "Did finish operation expectation")
        handler = { (notification: Notification) -> Void in
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
    }

    func testGivenGoodDataWhenCallingGetCommentsThenShouldSendTwoComments() {
        let commentModel = CommentModel(commentService: TestCommentGoodData())
        var comments: [Comment] = []
        handler = { (notification: Notification) -> Void in
            if let data = notification.userInfo as? [String: [Comment]] {
                for (_, result) in data {
                    comments = result
                }
            }
            self.didSendNotif = true
            self.testExpectation.fulfill()
        }
        let notif = NotificationCenter.default.addObserver(forName: .didSendComments,
                                                           object: nil, queue: nil, using: handler)

        commentModel.getComments(tid: "tid")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        XCTAssertEqual(comments.count, 2)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenGoodDataWhenCallingRegsiterCommentThenShouldSendRegisterNotification() {
        let commentModel = CommentModel(commentService: TestCommentGoodData())
        let notif = NotificationCenter.default.addObserver(forName: .didRegisterComment,
                                                           object: nil, queue: nil, using: handler)

        commentModel.registerComment(tid: "tid", comment: "Hello")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }

    func testGivenBadDataWhenCallingRegsiterCommentThenShouldSendRegisterNotification() {
        let commentModel = CommentModel(commentService: TestCommentBadData())
        let notif = NotificationCenter.default.addObserver(forName: .didSendError,
                                                           object: nil, queue: nil, using: handler)

        commentModel.registerComment(tid: "tid", comment: "Hello")

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didSendNotif)
        NotificationCenter.default.removeObserver(notif)
    }
}
