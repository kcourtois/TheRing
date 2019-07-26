//
//  UserController.swift
//  TheRing
//
//  Created by Kévin Courtois on 26/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserController: UIViewController {
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
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var tournamentsButton: UIButton!
    @IBOutlet weak var subscribersButton: UIButton!
    @IBOutlet weak var subscriptionsButton: UIButton!
    @IBOutlet weak var myCodeButton: UIButton!
    @IBOutlet weak var scanCodeButton: UIButton!

    private let preferences = Preferences()
    private var alert: UIAlertController?
    private var userType: UserListType = .subscriptions

    override func viewDidLoad() {
        super.viewDidLoad()
        setTexts()
        alert = loadingAlert()
        if let user = Auth.auth().currentUser {
            UserService.getUserInfo(uid: user.uid, completion: { user in
                if let user = user {
                    self.preferences.user = user
                    self.setLabels()
                    if let alert = self.alert {
                        alert.dismiss(animated: true, completion: nil)
                    }
                } else {
                    print("no user retrieved")
                    if let alert = self.alert {
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
            })
        } else {
            print("no user connected")
            if let alert = self.alert {
                alert.dismiss(animated: true, completion: nil)
            }
        }
        if let items = tabBarController?.tabBar.items {
            items[0].title = TRStrings.home.localizedString
            items[1].title = TRStrings.user.localizedString
            items[2].title = TRStrings.create.localizedString
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLabels()
    }

    @IBAction func seeTournaments(_ sender: Any) {
        performSegue(withIdentifier: "TournamentListSegue", sender: self)
    }

    @IBAction func updateProfileTapped() {
        performSegue(withIdentifier: "profileSegue", sender: self)
    }

    @IBAction func subscribersTapped(_ sender: Any) {
        userType = .subscribers
        performSegue(withIdentifier: "userListSegue", sender: self)
    }

    @IBAction func subscriptionsTapped(_ sender: Any) {
        userType = .subscriptions
        performSegue(withIdentifier: "userListSegue", sender: self)
    }

    @IBAction func myCodeTapped(_ sender: Any) {
        performSegue(withIdentifier: "myCodeSegue", sender: self)
    }

    @IBAction func scanCodeTapped(_ sender: Any) {
        performSegue(withIdentifier: "scanCodeSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userListSegue",
            let userListVC = segue.destination as? UserListController {
            userListVC.userType = userType
        }
    }

    private func setLabels() {
        mailLabel.text = preferences.user.email
        nameLabel.text = preferences.user.name
        genderLabel.text = preferences.user.gender.asString
        biographyLabel.text = preferences.user.bio
        UserService.getSubsciptionsCount(uid: preferences.user.uid) { (num) in
            if let num = num {
                self.subscriptionsLabel.text = "\(num)"
            }
        }
        UserService.getSubscribersCount(uid: preferences.user.uid) { (num) in
            if let num = num {
                self.subscribersLabel.text = "\(num)"
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
        updateButton.setTitle(TRStrings.updateProfile.localizedString, for: .normal)
        tournamentsButton.setTitle(TRStrings.seeTournaments.localizedString, for: .normal)
        subscribersButton.setTitle(TRStrings.mySubscribers.localizedString, for: .normal)
        subscriptionsButton.setTitle(TRStrings.mySubscriptions.localizedString, for: .normal)
    }

}
