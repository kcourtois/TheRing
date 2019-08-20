//
//  FirebaseVote.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth.FIRAuthErrors

class FirebaseVote: VoteService {
    //register a vote in the database
    func registerVote(rid: String, uid: String, cid: String,
                      completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let values = [uid: uid]
        reference.child("votes").child(rid).child(cid).updateChildValues(values,
                                                                         withCompletionBlock: { (error, _) in
            completion(self.getAuthError(error: error))
        })
    }

    //returns vote for given user and round if exists
    func getUserVote(uid: String, rid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("votes").child(rid).observeSingleEvent(of: .value, with: { (snapshot) in
            //loop through contestants of a round
            for case let data as DataSnapshot in snapshot.children {
                let value = data.value as? NSDictionary
                //if the uid of the user is a valid key, this is his vote
                if (value?[uid] as? String) != nil {
                    completion(data.key)
                }
            }
            completion(nil)
        })
    }

    //returns vote count for given contestant/round
    func getVotes(cid: String, rid: String, completion: @escaping (UInt?) -> Void) {
        let reference = Database.database().reference()
        reference.child("votes").child(rid).child(cid).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.childrenCount)
        })
        completion(nil)
    }

    //remove a vote for given user/round/contestant
    func removeUserVote(uid: String, rid: String, cid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("votes").child(rid).child(cid).child(uid).removeValue { (error, _) in
            completion(self.getAuthError(error: error))
        }
    }
}

// MARK: - Utilities
extension FirebaseVote {
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
