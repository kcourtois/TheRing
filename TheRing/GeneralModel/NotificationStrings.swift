//
//  NotificationStrings.swift
//  TheRing
//
//  Created by Kévin Courtois on 23/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class NotificationStrings {
    //Strings (const) for notification names and parameter keys in the app
    static let didTapContestantKey: String = "tag"
    static let didTapSubscribersKey: String = UserListType.subscribers.rawValue
    static let didTapSubscriptionsKey: String = UserListType.subscriptions.rawValue
    static let didSignInKey: String = "signIn"
    static let didSendErrorKey: String = "error"
}

extension Notification.Name {
    static let didTapContestant = Notification.Name("didTapContestant")
    static let didTapSubscribers = Notification.Name("didTapSubscribers")
    static let didTapSubscriptions = Notification.Name("didTapSubscriptions")
    static let didSignIn = Notification.Name("didSignIn")
    static let didSendError = Notification.Name("didSendError")
}
