//
//  FirebaseComment.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth.FIRAuthErrors

class FirebaseComment: CommentService {
    //registers a comment for the current user
    func registerComment(tid: String, comment: String,
                         completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let pref = Preferences()
        //get current date to string
        guard let date = Date().dateToString() else {
            return
        }
        let values = ["uid": pref.user.uid, "username": pref.user.name, "comment": comment, "date": date]
        let cid = generateId()
        //add comment in database
        reference.child("comments").child(tid).child(cid).updateChildValues(values,
                                                                            withCompletionBlock: { (error, _) in
            completion(self.getAuthError(error: error))
        })
    }

    //returns comments for given tournament
    func getComments(tid: String, completion: @escaping ([Comment]) -> Void) {
        let reference = Database.database().reference()
        var comments = [Comment]()
        reference.child("comments").child(tid).observeSingleEvent(of: .value, with: { (snapshot) in
            //get values for each comment (child of the tournament)
            for case let data as DataSnapshot in snapshot.children {
                let value = data.value as? NSDictionary
                if let uid = value?["uid"] as? String,
                    let username = value?["username"] as? String,
                    let comment = value?["comment"] as? String {
                    comments.append(Comment(cid: data.key, uid: uid, username: username, comment: comment))
                }
            }
            completion(comments)
        })
    }
}

// MARK: - Utilities
extension FirebaseComment {
    //Generate id based on date and random int
    private func generateId() -> String {
        let rand = Int.random(in: 1000 ..< 9000)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMddhmmssSSSS"
        let now = dateformatter.string(from: Date())
        return "\(now)\(rand)"
    }

    //return localized string for given error
    private func getAuthError(error: Error?) -> String? {
        guard let error = error else {
            return nil
        }
        guard let authError = AuthErrorCode(rawValue: error._code) else {
            return nil
        }
        return LocalizedString(key: authError.errorMessage).val
    }
}
