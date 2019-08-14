//
//  TestUserBadData.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class TestUserBadData: UserService {
    func getUserInfo(uid: String, completion: @escaping (TRUser?) -> Void) {

    }

    func isUsernameAvailable(name: String, completion: @escaping (Bool) -> Void) {
        completion(false)
    }

    func registerUserInfo(uid: String, values: [String: Any], completion: @escaping (String?) -> Void) {

    }

    func registerUsername(name: String, uid: String, completion: @escaping (String?) -> Void) {

    }

    func unregisterUsername(name: String, completion: @escaping (String?) -> Void) {

    }

    func replaceUsername(old: String, new: String, uid: String, completion: @escaping (String?) -> Void) {

    }

    func getUserSubscribers(completion: @escaping ([TRUser]) -> Void) {

    }

    func getUserSubscriptions(completion: @escaping ([TRUser]) -> Void) {

    }

    func isUserSubbedToUid(uid: String, completion: @escaping (Bool) -> Void) {

    }

    func subToUser(uid: String, completion: @escaping (String?) -> Void) {

    }

    func unsubToUser(uid: String) {

    }

    func getSubscribersCount(uid: String, completion: @escaping (UInt?) -> Void) {

    }

    func getSubsciptionsCount(uid: String, completion: @escaping (UInt?) -> Void) {

    }
}
