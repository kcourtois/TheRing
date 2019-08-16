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
    static let didSendErrorKey: String = "error"
    static let didSignInKey: String = "signIn"
    static let didSignUpKey: String = "signUp"
    static let didSendTournamentDataKey: String = "tournamentData"

}

extension Notification.Name {
    static let didTapContestant = Notification.Name("didTapContestant")
    static let didTapSubscribers = Notification.Name("didTapSubscribers")
    static let didTapSubscriptions = Notification.Name("didTapSubscriptions")
    static let didSendError = Notification.Name("didSendError")
    static let didSignIn = Notification.Name("didSignIn")
    static let didSignUp = Notification.Name("didSignUp")
    static let didSendTournamentData = Notification.Name("didSendTournamentData")
}
