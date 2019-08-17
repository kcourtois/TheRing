//
//  TestUserBadData.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 17/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class TestUserBadData: UserService {
    func getUserInfo(uid: String, completion: @escaping (TRUser?) -> Void) {
        completion(nil)
    }

    func isUsernameAvailable(name: String, completion: @escaping (Bool) -> Void) {}

    func registerUserInfo(uid: String, values: [String: Any], completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    func registerUsername(name: String, uid: String, completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    func unregisterUsername(name: String, completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    func replaceUsername(old: String, new: String, uid: String, completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    func getUserSubscribers(completion: @escaping ([TRUser]) -> Void) {
        completion([])
    }

    func getUserSubscriptions(completion: @escaping ([TRUser]) -> Void) {
        completion([])
    }

    func isUserSubbedToUid(uid: String, completion: @escaping (Bool) -> Void) {}

    func subToUser(uid: String, completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    func unsubToUser(uid: String, completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    func getSubscribersCount(uid: String, completion: @escaping (UInt?) -> Void) {
        completion(nil)
    }

    func getSubscriptionsCount(uid: String, completion: @escaping (UInt?) -> Void) {
        completion(nil)
    }
}
