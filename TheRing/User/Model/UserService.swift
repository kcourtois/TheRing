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
        //reference to firebase database
        let reference = Database.database().reference()
        //go to child node to fetch values
        reference.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let name = value?["username"] as? String,
                let gender = Gender(rawValue: value?["gender"] as? Int ?? 2),
                let email = value?["email"] as? String,
                let bio = value?["bio"] as? String {
                //if we have all the keys, create a user and return it in completion
                completion(TRUser(uid: uid, name: name, gender: gender, email: email, bio: bio))
            } else {
                //else completion is nil
                completion(nil)
            }
        })
    }

    //check if username is available or aleardy used
    static func isUsernameAvailable(name: String, completion: @escaping (Bool) -> Void) {
        let reference = Database.database().reference()
        reference.child("usernames").child(name).observeSingleEvent(of: .value, with: { (snapshot) in
            //check if the value exists, and return true if not
            completion(!snapshot.exists())
        }, withCancel: nil)
    }

    //register user informations such as username, gender, bio...
    static func registerUserInfo(uid: String, values: [String: Any], completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("users").child(uid).updateChildValues(values) { (error, _) in
            //completion gives a string based on firebase error, if an error occured
            completion(FirebaseAuthService.getAuthError(error: error))
        }
    }

    //register username for future use
    static func registerUsername(name: String, uid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("usernames").updateChildValues([name: uid], withCompletionBlock: { (error, _) in
            //completion gives a string based on firebase error, if an error occured
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

    //unregister username from db
    static func unregisterUsername(name: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("usernames/\(name)").removeValue { (error, _) in
            //completion gives a string based on firebase error, if an error occured
            completion(FirebaseAuthService.getAuthError(error: error))
        }
    }

    //replace old username by a new one
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
        //dispatch group created
        let group = DispatchGroup()
        group.enter()
        reference.child("user_subscribers").child(preferences.user.uid).observeSingleEvent(of: .value,
                                                                                           with: { (snapshot) in
            //for each uid in user subs, get the user infos
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
        //Once all the tasks are done (all user info retrieved), we can call completion
        group.notify(queue: .main) {
            completion(users)
        }
    }

    //returns a list of subscribers for current user
    static func getUserSubscriptions(completion: @escaping ([TRUser]) -> Void) {
        var users = [TRUser]()
        let reference = Database.database().reference()
        let preferences = Preferences()
        //dispatch group created
        let group = DispatchGroup()
        group.enter()
        reference.child("user_subscriptions").child(preferences.user.uid).observeSingleEvent(of: .value,
                                                                                           with: { (snapshot) in
            //for each uid in user subs, get the user infos
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
        //Once all the tasks are done (all user info retrieved), we can call completion
        group.notify(queue: .main) {
            completion(users)
        }
    }

    //returns subscribers count for given user
    static func isUserSubbedToUid(uid: String, completion: @escaping (Bool) -> Void) {
        let reference = Database.database().reference()
        let user = Preferences().user.uid
        reference.child("user_subscriptions").child(user).child(uid).observeSingleEvent(of: .value,
                                                                                            with: { (snapshot) in
            //if uid is found in user subscriptions, then user is subbed
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        })
    }

    //sub current user to provided user
    static func subToUser(uid: String, completion: @escaping (String?) -> Void) {
        registerSubscription(uid: uid) { (error) in
            if let error = error {
                completion(error)
                return
            } else {
                registerSubscriber(uid: uid, completion: { (error) in
                    if let error = error {
                        completion(error)
                        return
                    } else {
                        completion(nil)
                    }
                })
            }
        }
    }

    //sub current user to provided user
    static func unsubToUser(uid: String) {
        unregisterSubscription(uid: uid)
        unregisterSubscriber(uid: uid)
    }

    //returns subscribers count for given user
    static func getSubscribersCount(uid: String, completion: @escaping (UInt?) -> Void) {
        let reference = Database.database().reference()
        reference.child("user_subscribers").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            //get children count for user subscribers at given uid
            completion(snapshot.childrenCount)
        })
        completion(nil)
    }

    //returns subscriptions count for given user
    static func getSubsciptionsCount(uid: String, completion: @escaping (UInt?) -> Void) {
        let reference = Database.database().reference()
        //get children count for user subscriptions at given uid
        reference.child("user_subscriptions").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.childrenCount)
        })
        completion(nil)
    }

    //register a subscriber for the given uid
    static private func registerSubscriber(uid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let user = Preferences().user.uid
        let values = [user: user]
        reference.child("user_subscribers").child(uid).updateChildValues(values,
                                                                         withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

    //unregister a subscriber for the given uid
    static private func unregisterSubscriber(uid: String) {
        let reference = Database.database().reference()
        let user = Preferences().user.uid
        reference.child("user_subscribers").child(uid).child(user).removeValue()
    }

    //register a subscription for the current user
    static private func registerSubscription(uid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let user = Preferences().user.uid
        let values = [uid: uid]
        reference.child("user_subscriptions").child(user).updateChildValues(values,
                                                                              withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

     //unregister a subscription for the current user
    static private func unregisterSubscription(uid: String) {
        let reference = Database.database().reference()
        let user = Preferences().user.uid
        reference.child("user_subscriptions").child(user).child(uid).removeValue()
    }
}
