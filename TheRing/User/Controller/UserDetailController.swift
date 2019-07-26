//
//  UserDetailController.swift
//  TheRing
//
//  Created by Kévin Courtois on 27/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class UserDetailController: UIViewController {
    @IBOutlet weak var subscribersDesc: UILabel!
    @IBOutlet weak var subscriptionsDesc: UILabel!
    @IBOutlet weak var usernameDesc: UILabel!
    @IBOutlet weak var emailDesc: UILabel!
    @IBOutlet weak var genderDesc: UILabel!
    @IBOutlet weak var bioDesc: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var subscriptionsLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!

    var uid: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setTexts()
        setLabels()
    }

    @IBAction func subscribeTapped(_ sender: Any) {
    }

    private func setLabels() {
        if let uid = uid {
            UserService.getUserInfo(uid: uid) { (user) in
                if let user = user {
                    self.mailLabel.text = user.email
                    self.nameLabel.text = user.name
                    self.genderLabel.text = user.gender.asString
                    self.biographyLabel.text = user.bio
                    self.title = user.name
                    self.subscribeButton.setTitle(TRStrings.subscribe.localizedString, for: .normal)
                    UserService.getSubsciptionsCount(uid: user.uid) { (num) in
                        if let num = num {
                            self.subscriptionsLabel.text = "\(num)"
                        }
                    }
                    UserService.getSubscribersCount(uid: user.uid) { (num) in
                        if let num = num {
                            self.subscribersLabel.text = "\(num)"
                        }
                    }
                }
            }
        }
    }

    private func setTexts() {
        self.title = TRStrings.profile.localizedString
        usernameDesc.text = TRStrings.username.localizedString
        emailDesc.text = TRStrings.email.localizedString
        genderDesc.text = TRStrings.gender.localizedString
        bioDesc.text = TRStrings.bio.localizedString
        subscribersDesc.text = TRStrings.subscribers.localizedString
        subscriptionsDesc.text = TRStrings.subscriptions.localizedString
    }
}
