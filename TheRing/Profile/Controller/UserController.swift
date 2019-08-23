//
//  UserController.swift
//  TheRing
//
//  Created by Kévin Courtois on 26/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

//User controller shows current user profile, and gives access to add friends or update profile options
class UserController: UIViewController {

    @IBOutlet weak var userInfoView: UserInfoView!
    @IBOutlet weak var myCodeButton: UIButton!

    private let userDetailModel = UserDetailModel(userService: FirebaseUser())
    private var userType: UserListType = .subscriptions
    private let preferences = Preferences()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set texts for this screen
        setTexts()
        //check if user is logged in
        checkUserLogged()
        //set texts that requires data
        setLabels()
        //set observers for notifications
        setObservers()
    }

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didTapSubscribers
        NotificationCenter.default.addObserver(self, selector: #selector(onDidTapSubscribers),
                                               name: .didTapSubscribers, object: nil)
        //Notification observer for didTapSubscriptions
        NotificationCenter.default.addObserver(self, selector: #selector(onDidTapSubscriptions),
                                               name: .didTapSubscriptions, object: nil)
        //Notification observer for didSendCount
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendCount),
                                               name: .didSendCount, object: nil)
        //Notification observer for didSendError
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
    }

    //removes observers on deinit
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //remove observers on view disappear
        NotificationCenter.default.removeObserver(self, name: .didSendCount, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didTapSubscribers, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didTapSubscriptions, object: nil)
    }

    //Triggers on notification didTapSubscribers
    @objc private func onDidTapSubscribers(_ notification: Notification) {
        userType = .subscribers
        performSegue(withIdentifier: "userListSegue", sender: self)
    }

    //Triggers on notification didTapSubscriptions
    @objc private func onDidTapSubscriptions(_ notification: Notification) {
        userType = .subscriptions
        performSegue(withIdentifier: "userListSegue", sender: self)
    }

    @IBAction func updateProfileTapped() {
        performSegue(withIdentifier: "profileSegue", sender: self)
    }

    @IBAction func myCodeTapped(_ sender: Any) {
        performSegue(withIdentifier: "showCodeSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userListSegue",
            let userListVC = segue.destination as? UserListController {
            userListVC.userType = userType
        }
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

    //Triggers on notification didSendError
    @objc private func onDidSendError(_ notification: Notification) {
        if let data = notification.userInfo as? [String: String] {
            for (_, error) in data {
                presentAlert(title: TRStrings.error.localizedString, message: error)
            }
        }
    }
}

// MARK: - UI & Preferences setup
extension UserController {
    //set texts for this screen
    private func setTexts() {
        self.title = TRStrings.profile.localizedString
        myCodeButton.setTitle(TRStrings.addFriends.localizedString, for: .normal)
        if let items = tabBarController?.tabBar.items {
            items[0].title = TRStrings.home.localizedString
            items[1].title = TRStrings.user.localizedString
            items[2].title = TRStrings.tournaments.localizedString
        }
    }

    //sets data label texts
    private func setLabels() {
        userInfoView.setUser(user: preferences.user)
        userDetailModel.getSubscriptionsCount(uid: preferences.user.uid)
        userDetailModel.getSubscribersCount(uid: preferences.user.uid)
    }
}
