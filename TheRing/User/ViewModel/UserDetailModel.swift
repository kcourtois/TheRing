//
//  UserDetailModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 11/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

//Model for UserDetail Controller
class UserDetailModel {
    private let userService: UserService

    init(userService: UserService) {
        self.userService = userService
    }

    //sub current user to given uid
    func subToUser(uid: String) {
        userService.subToUser(uid: uid) { (error) in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.postSubNotification(subKey: NotificationStrings.didSubKey)
            }
        }
    }

    //unsub current user to given uid
    func unsubToUser(uid: String) {
        userService.unsubToUser(uid: uid) { (error) in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.postSubNotification(subKey: NotificationStrings.didUnsubKey)
            }
        }
    }

    //check if current user is subbed to given user
    func userSubbedToUid(uid: String) {
        userService.isUserSubbedToUid(uid: uid) { (isSubbed) in
            self.postIsUserSubbedNotification(subbed: isSubbed)
        }
    }

    //get subscribers count for given uid
    func getSubscribersCount(uid: String) {
        //fetch subscribers count
        userService.getSubscribersCount(uid: uid) { (num) in
            if let num = num {
                self.postCountNotification(num: num, key: NotificationStrings.didSendSubscribersCountKey)
            } else {
                self.postErrorNotification(error: TRStrings.errorOccured.localizedString)
            }
        }
    }

    //get subscriptions count for given uid
    func getSubscriptionsCount(uid: String) {
        //fetch subscriptions count
        userService.getSubscriptionsCount(uid: uid) { (num) in
            if let num = num {
                self.postCountNotification(num: num, key: NotificationStrings.didSendSubscriptionsCountKey)
            } else {
                self.postErrorNotification(error: TRStrings.errorOccured.localizedString)
            }
        }
    }

    //send count notification
    private func postCountNotification(num: UInt, key: String) {
        NotificationCenter.default.post(name: .didSendCount, object: nil,
                                        userInfo: [key: num])
    }

    //send isUserSubbed notification
    private func postIsUserSubbedNotification(subbed: Bool) {
        NotificationCenter.default.post(name: .didSendIsUserSubbed, object: nil,
                                        userInfo: [NotificationStrings.didSendIsUserSubbedKey: subbed])
    }

    //send subbed notification
    private func postSubNotification(subKey: String) {
        NotificationCenter.default.post(name: .didSendSub, object: nil,
                                        userInfo: [subKey: subKey])
    }

    //send error notification
    private func postErrorNotification(error: String) {
        NotificationCenter.default.post(name: .didSendError, object: nil,
                                        userInfo: [NotificationStrings.didSendErrorKey: error])
    }
}
