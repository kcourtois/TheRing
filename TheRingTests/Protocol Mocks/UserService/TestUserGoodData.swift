//
//  TestUserGoodData.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class TestUserGoodData: UserService {
    func getUserInfo(uid: String, completion: @escaping (TRUser?) -> Void) {
        completion(TRUser(uid: "uid", name: "name", gender: .other, email: "email", bio: "bio"))
    }

    func isUsernameAvailable(name: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func registerUserInfo(uid: String, values: [String: Any], completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func registerUsername(name: String, uid: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func unregisterUsername(name: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func replaceUsername(old: String, new: String, uid: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func getUserSubscribers(completion: @escaping ([TRUser]) -> Void) {
        completion([TRUser(uid: "uid0", name: "name0", gender: .other, email: "email0", bio: "bio0"),
                    TRUser(uid: "uid1", name: "name1", gender: .other, email: "email1", bio: "bio1")])
    }

    func getUserSubscriptions(completion: @escaping ([TRUser]) -> Void) {
        completion([TRUser(uid: "uid0", name: "name0", gender: .other, email: "email0", bio: "bio0"),
                    TRUser(uid: "uid1", name: "name1", gender: .other, email: "email1", bio: "bio1"),
                    TRUser(uid: "uid2", name: "name2", gender: .other, email: "email2", bio: "bio2")])
    }

    func isUserSubbedToUid(uid: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func subToUser(uid: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func unsubToUser(uid: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func getSubscribersCount(uid: String, completion: @escaping (UInt?) -> Void) {
        completion(5)
    }

    func getSubscriptionsCount(uid: String, completion: @escaping (UInt?) -> Void) {
        completion(3)
    }
}
