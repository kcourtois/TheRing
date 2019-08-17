//
//  UserService.swift
//  TheRing
//
//  Created by Kévin Courtois on 27/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

protocol UserService {
    //get user info online
    func getUserInfo(uid: String, completion: @escaping (TRUser?) -> Void)

    //check if username is available or aleardy used
    func isUsernameAvailable(name: String, completion: @escaping (Bool) -> Void)

    //register user informations such as username, gender, bio...
    func registerUserInfo(uid: String, values: [String: Any], completion: @escaping (String?) -> Void)

    //register username for future use
    func registerUsername(name: String, uid: String, completion: @escaping (String?) -> Void)

    //unregister username from db
    func unregisterUsername(name: String, completion: @escaping (String?) -> Void)

    //replace old username by a new one
    func replaceUsername(old: String, new: String, uid: String, completion: @escaping (String?) -> Void)

    //returns a list of subscribers for current user
    func getUserSubscribers(completion: @escaping ([TRUser]) -> Void)

    //returns a list of subscriptions for current user
    func getUserSubscriptions(completion: @escaping ([TRUser]) -> Void)

    //check if user is subbed to an other user
    func isUserSubbedToUid(uid: String, completion: @escaping (Bool) -> Void)

    //sub current user to provided user
    func subToUser(uid: String, completion: @escaping (String?) -> Void)

    //unsub current user to provided user
    func unsubToUser(uid: String, completion: @escaping (String?) -> Void)

    //returns subscribers count for given user
    func getSubscribersCount(uid: String, completion: @escaping (UInt?) -> Void)

    //returns subscriptions count for given user
    func getSubscriptionsCount(uid: String, completion: @escaping (UInt?) -> Void)
}
