//
//  UserService.swift
//  TheRing
//
//  Created by Kévin Courtois on 27/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserService {
    //get user info online
    static func getUserInfo(uid: String, completion: @escaping (TRUser?) -> Void) {
        let reference = Database.database().reference()
        reference.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let name = value?["username"] as? String,
                let gender = Gender(rawValue: value?["gender"] as? Int ?? 2),
                let email = value?["email"] as? String,
                let bio = value?["bio"] as? String {
                completion(TRUser(uid: uid, name: name, gender: gender, email: email, bio: bio))
            } else {
                completion(nil)
            }
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
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

    //register username for future use
    static func registerUsername(name: String, uid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("usernames").updateChildValues([name: uid], withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

    //unregister username from db
    static func unregisterUsername(name: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("usernames/\(name)").removeValue { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
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

    //returns a list of subscribers for current user
    static func getUserSubscribers(completion: @escaping ([TRUser]) -> Void) {
        var users = [TRUser]()
        let reference = Database.database().reference()
        let preferences = Preferences()
        let group = DispatchGroup()
        group.enter()
        reference.child("user_subscribers").child(preferences.user.uid).observeSingleEvent(of: .value,
                                                                                           with: { (snapshot) in
            for case let data as DataSnapshot in snapshot.children {
                group.enter()
                if let uid = data.value as? String {
                    getUserInfo(uid: uid, completion: { (user) in
                        if let user = user {
                            users.append(user)
                            group.leave()
                        }
                    })
                }
            }
            group.leave()
        })
        group.notify(queue: .main) {
            completion(users)
        }
    }

    //returns a list of subscribers for current user
    static func getUserSubscriptions(completion: @escaping ([TRUser]) -> Void) {
        var users = [TRUser]()
        let reference = Database.database().reference()
        let preferences = Preferences()
        let group = DispatchGroup()
        group.enter()
        reference.child("user_subscriptions").child(preferences.user.uid).observeSingleEvent(of: .value,
                                                                                           with: { (snapshot) in
            for case let data as DataSnapshot in snapshot.children {
                group.enter()
                if let uid = data.value as? String {
                    getUserInfo(uid: uid, completion: { (user) in
                        if let user = user {
                            users.append(user)
                            group.leave()
                        }
                    })
                }
            }
            group.leave()
        })
        group.notify(queue: .main) {
            completion(users)
        }
    }

    //returns subscribers count for given user
    static func getSubscribersCount(uid: String, completion: @escaping (UInt?) -> Void) {
        let reference = Database.database().reference()
        reference.child("username_subscribers").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.childrenCount)
        })
        completion(nil)
    }

    //returns subscriptions count for given user
    static func getSubsciptionsCount(uid: String, completion: @escaping (UInt?) -> Void) {
        let reference = Database.database().reference()
        reference.child("username_subscriptions").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.childrenCount)
        })
        completion(nil)
    }

    static private func registerSubscriber(uid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let pref = Preferences()
        let values = [pref.user.uid: pref.user.uid]
        reference.child("user_subscribers").child(uid).updateChildValues(values,
                                                                         withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

    static private func registerSubscription(uid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let currId = Preferences().user.uid
        let values = [uid: uid]
        reference.child("user_subscriptions").child(currId).updateChildValues(values,
                                                                              withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }
}
