//
//  NotificationStrings.swift
//  TheRing
//
//  Created by Kévin Courtois on 23/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class NotificationStrings {
    //Strings (const) for parameter keys in the app
    static let didTapContestantKey: String = "tag"
    static let didTapSubscribersKey: String = UserListType.subscribers.rawValue
    static let didTapSubscriptionsKey: String = UserListType.subscriptions.rawValue
    static let didSendErrorKey: String = "error"
    static let didSignInKey: String = "signIn"
    static let didSignUpKey: String = "signUp"
    static let didSendTournamentDataKey: String = "tournamentData"
    static let didSendSubsKey: String = "subs"
    static let didSendUserInfoKey: String = "user"
    static let didSendSubscribersCountKey: String = "subscribersCount"
    static let didSendSubscriptionsCountKey: String = "subscriptionsCount"
    static let didSubKey: String = "subbed"
    static let didUnsubKey: String = "unsubbed"
    static let didSendIsUserSubbedKey: String = "isSubbed"
}

extension Notification.Name {
    //const for notification names in the app
    static let didTapContestant = Notification.Name("didTapContestant")
    static let didTapSubscribers = Notification.Name("didTapSubscribers")
    static let didTapSubscriptions = Notification.Name("didTapSubscriptions")
    static let didSendError = Notification.Name("didSendError")
    static let didSignIn = Notification.Name("didSignIn")
    static let didSignUp = Notification.Name("didSignUp")
    static let didSendTournamentData = Notification.Name("didSendTournamentData")
    static let didSendSubs = Notification.Name("didSendSubs")
    static let didSendUserInfo = Notification.Name("didSendUserInfo")
    static let didSendCount = Notification.Name("didSendCount")
    static let didSendSub = Notification.Name("didSendSub")
    static let didSendIsUserSubbed = Notification.Name("didSendIsUserSubbed")
}
