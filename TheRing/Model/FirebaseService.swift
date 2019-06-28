//
//  FirebaseService.swift
//  TheRing
//
//  Created by Kévin Courtois on 27/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseService {
    //get user info online
    static func getUserInfo(uid: String) {
        let preferences = Preferences()
        let reference = Database.database().reference()
        reference.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            preferences.user = User(uid: uid,
                                    name: value?["username"] as? String ?? "Unknown",
                                    gender: Gender(rawValue: value?["gender"] as? Int ?? 2) ?? .other,
                                    email: value?["email"] as? String ?? "Unknown",
                                    bio: value?["bio"] as? String ?? "Unknown")
        })
    }

    //check if username is available or aleardy used
    static func isUsernameAvailable(name: String, completion: @escaping (Bool) -> Void) {
        let reference = Database.database().reference()
        reference.child("usernames").child(name).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(!snapshot.exists())
        }, withCancel: nil)
    }

    //register user informations such as username, gender, bio...
    static func registerUserInfo(uid: String, values: [String: Any], completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("users").child(uid).updateChildValues(values,
                                                              withCompletionBlock: { (error, _) in
            completion(error?.localizedDescription)
        })
    }

    //register username for future use
    static func registerUsername(name: String, uid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("usernames").updateChildValues([name: uid], withCompletionBlock: { (error, _) in
            completion(error?.localizedDescription)
        })
    }

    //unregister username from db
    static func unregisterUsername(name: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("usernames/\(name)").removeValue { (error, _) in
            completion(error?.localizedDescription)
        }
    }

    static func replaceUsername(old: String, new: String, uid: String, completion: @escaping (String?) -> Void) {
        unregisterUsername(name: old) { (error) in
            if error != nil {
                completion(error)
            }
            registerUsername(name: new, uid: uid, completion: { (error) in
                completion(error)
            })
        }
    }
}
