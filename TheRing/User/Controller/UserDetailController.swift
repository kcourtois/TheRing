//
//  UserDetailController.swift
//  TheRing
//
//  Created by Kévin Courtois on 27/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

//user detail controller, will show the profile of a given user
class UserDetailController: UIViewController {

    @IBOutlet weak var userInfoView: UserInfoView!
    @IBOutlet weak var subscribeButton: UIButton!

    private let userDetailModel = UserDetailModel(userService: FirebaseUser())
    private var subbed: Bool = false {
        didSet {
            if subbed {
                subscribeButton.setTitle(TRStrings.unsubscribe.localizedString, for: .normal)
            } else {
                subscribeButton.setTitle(TRStrings.subscribe.localizedString, for: .normal)
            }
        }
    }
    var user: TRUser?

    override func viewWillAppear(_ animated: Bool) {
        //set observers on view appear
        super.viewWillAppear(animated)
        //set observers for notifications
        setObservers()
        //set texts for this screen
        setTexts()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //remove observers on view disappear
        NotificationCenter.default.removeObserver(self, name: .didSendCount, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendSub, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendIsUserSubbed, object: nil)
    }

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didSendCount
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendCount),
                                               name: .didSendCount, object: nil)
        //Notification observer for didSendError
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
        //Notification observer for didSendIsUserSubbed
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendIsUserSubbed),
                                               name: .didSendIsUserSubbed, object: nil)
        //Notification observer for didSendSubbed
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendSubbed),
                                               name: .didSendSub, object: nil)
    }

    //Sub / Unsub to user when button tapped
    @IBAction func subscribeTapped(_ sender: Any) {
        if let user = user {
            if subbed {
                userDetailModel.unsubToUser(uid: user.uid)
            } else {
                userDetailModel.subToUser(uid: user.uid)
            }
        }
    }

    //set texts for this screen
    private func setTexts() {
        if let user = user {
            userInfoView.setUser(user: user)
            self.title = user.name
            //fetch subscriptions count
            userDetailModel.getSubscriptionsCount(uid: user.uid)
            //fetch subscribers count
            userDetailModel.getSubscribersCount(uid: user.uid)
            //check if current user is subbed to detail user
            userDetailModel.userSubbedToUid(uid: user.uid)
        }
    }

    //Triggers on notification didSendError
    @objc private func onDidSendError(_ notification: Notification) {
        if let data = notification.userInfo as? [String: String] {
            for (_, error) in data {
                presentAlert(title: TRStrings.error.localizedString, message: error)
            }
        }
    }

    //Triggers on notification didSendIsUserSubbed
    @objc private func onDidSendIsUserSubbed(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            for (_, isSubbed) in data {
                self.subbed = isSubbed
            }
        }
    }

    //Triggers on notification didSendSubbed
    @objc private func onDidSendSubbed(_ notification: Notification) {
        subbed = !subbed
    }

    //Triggers on notification didSendCount
    @objc private func onDidSendCount(_ notification: Notification) {
        if let data = notification.userInfo as? [String: UInt] {
            for (label, num) in data {
                if label == NotificationStrings.didSendSubscribersCountKey {
                    self.userInfoView.setSubscribersCount(count: num)
                } else if label == NotificationStrings.didSendSubscriptionsCountKey {
                    self.userInfoView.setSubscriptionsCount(count: num)
                }
            }
        }
    }
}
