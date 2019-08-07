//
//  NotificationStrings.swift
//  TheRing
//
//  Created by Kévin Courtois on 23/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class NotificationStrings {
    static let didTapContestantNotificationName: String = "didTapContestant"
    static let didTapContestantParameterKey: String = "tag"
    static let didTapSubscribersNotificationName: String = "didTapSubscribers"
    static let didTapSubscribersParameterKey: String = UserListType.subscribers.rawValue
    static let didTapSubscriptionsNotificationName: String = "didTapSubscriptions"
    static let didTapSubscriptionsParameterKey: String = UserListType.subscriptions.rawValue
}
