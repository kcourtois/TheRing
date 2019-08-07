//
//  UserDetailController.swift
//  TheRing
//
//  Created by Kévin Courtois on 27/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class UserDetailController: UIViewController {

    @IBOutlet weak var userInfoView: UserInfoView!
    @IBOutlet weak var subscribeButton: UIButton!

    var user: TRUser?
    private var subbed: Bool = false {
        didSet {
            if subbed {
                subscribeButton.setTitle(TRStrings.unsubscribe.localizedString, for: .normal)
            } else {
                subscribeButton.setTitle(TRStrings.subscribe.localizedString, for: .normal)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set texts for this screen
        setTexts()
    }

    //Sub / Unsub to user when button tapped
    @IBAction func subscribeTapped(_ sender: Any) {
        if let user = user {
            if subbed {
                UserService.unsubToUser(uid: user.uid)
            } else {
                UserService.subToUser(uid: user.uid) { (error) in
                    if let error = error {
                        self.presentAlert(title: TRStrings.error.localizedString, message: error)
                    }
                }
            }
            subbed = !subbed
        }
    }

    //set texts for this screen
    private func setTexts() {
        if let user = user {
            userInfoView.setUser(user: user)
            self.title = user.name
            //fetch subscriptions count
            UserService.getSubsciptionsCount(uid: user.uid) { (num) in
                if let num = num {
                    self.userInfoView.setSubscriptionsCount(count: num)
                }
            }
            //fetch subscribers count
            UserService.getSubscribersCount(uid: user.uid) { (num) in
                if let num = num {
                    self.userInfoView.setSubscribersCount(count: num)
                }
            }
            //check if current user is subbed to detail user
            UserService.isUserSubbedToUid(uid: user.uid) { (isSubbed) in
                self.subbed = isSubbed
            }
        }
    }
}