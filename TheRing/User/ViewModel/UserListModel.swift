//
//  UserListModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 11/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class UserListModel {
    private let userService: UserService

    init(userService: UserService) {
        self.userService = userService
    }

    //get subscribers or subscriptions for current user
    func getSubs(userType: UserListType) {
        switch userType {
        case .subscribers:
            //Get list of subscribers for current user
            userService.getUserSubscribers(completion: { (users) in
                self.postSubsNotification(users: users)
            })
        case .subscriptions:
            //Get list of subscriptions for current user
            userService.getUserSubscriptions(completion: { (users) in
                self.postSubsNotification(users: users)
            })
        }
    }

    //get user info for given uid
    func getUserInfo(uid: String) {
        userService.getUserInfo(uid: uid) { (user) in
            if let user = user {
                self.postUserInfoNotification(user: user)
            } else {
                self.postErrorNotification(error: TRStrings.errorOccured.localizedString)
            }

        }
    }

    //send error notification
    private func postErrorNotification(error: String) {
        NotificationCenter.default.post(name: .didSendError, object: nil,
                                        userInfo: [NotificationStrings.didSendErrorKey: error])
    }

    //send subs notification
    private func postSubsNotification(users: [TRUser]) {
        NotificationCenter.default.post(name: .didSendSubs, object: nil,
                                        userInfo: [NotificationStrings.didSendSubsKey: users])
    }

    //send userinfo notification
    private func postUserInfoNotification(user: TRUser) {
        NotificationCenter.default.post(name: .didSendUserInfo, object: nil,
                                        userInfo: [NotificationStrings.didSendUserInfoKey: user])
    }
}
