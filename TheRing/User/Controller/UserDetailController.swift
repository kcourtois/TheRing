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
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var subscriptionsLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!

    var user: TRUser?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTexts()
        setDescs()
    }

    @IBAction func subscribeTapped(_ sender: Any) {
    }

    private func setDescs() {
        if let user = user {
            self.emailDesc.text = user.email
            self.usernameDesc.text = user.name
            self.genderDesc.text = user.gender.asString
            self.bioDesc.text = user.bio
            self.title = user.name
            self.subscribeButton.setTitle(TRStrings.subscribe.localizedString, for: .normal)
            UserService.getSubsciptionsCount(uid: user.uid) { (num) in
                if let num = num {
                    self.subscriptionsDesc.text = "\(num)"
                }
            }
            UserService.getSubscribersCount(uid: user.uid) { (num) in
                if let num = num {
                    self.subscribersDesc.text = "\(num)"
                }
            }
        }
    }

    private func setTexts() {
        nameLabel.text = TRStrings.username.localizedString
        emailDesc.text = TRStrings.email.localizedString
        genderLabel.text = TRStrings.gender.localizedString
        biographyLabel.text = TRStrings.bio.localizedString
        subscribersLabel.text = TRStrings.subscribers.localizedString
        subscriptionsLabel.text = TRStrings.subscriptions.localizedString
    }
}
