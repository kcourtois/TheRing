//
//  UserController.swift
//  TheRing
//
//  Created by Kévin Courtois on 26/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class UserController: UIViewController {

    @IBOutlet weak var userInfoView: UserInfoView!
    @IBOutlet weak var myCodeButton: UIButton!

    private let preferences = Preferences()
    private let userService: UserService = FirebaseUser()
    private let authService: AuthService = FirebaseAuth()
    private var userType: UserListType = .subscriptions

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set texts for this screen
        setTexts()
        if let uid = authService.getLoggedUserUID() {
            //Check if user pref are up to date
            if preferences.user.uid != uid {
                loadUserPref(uid: uid)
            } else {
                //set texts that requires data
                setLabels()
                setObservers()
            }
        } else {
            userNotLogged()
        }
    }

    private func setObservers() {
        super.viewDidLoad()
        //Notification observer for didTapSubscribers
        let subscribersNotif = Notification.Name(rawValue: NotificationStrings.didTapSubscribersNotificationName)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidTapSubscribers),
                                               name: subscribersNotif, object: nil)
        //Notification observer for didTapSubscriptions
        let subscriptionsNotif = Notification.Name(rawValue:
            NotificationStrings.didTapSubscriptionsNotificationName)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidTapSubscriptions),
                                               name: subscriptionsNotif, object: nil)
    }

    //removes observers on deinit
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let subscribersNotif = Notification.Name(rawValue: NotificationStrings.didTapSubscribersNotificationName)
        let subscriptionsNotif = Notification.Name(rawValue:
            NotificationStrings.didTapSubscriptionsNotificationName)
        NotificationCenter.default.removeObserver(self, name: subscribersNotif, object: nil)
        NotificationCenter.default.removeObserver(self, name: subscriptionsNotif, object: nil)
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
}

// MARK: - UI & Preferences setup
extension UserController {
    //set texts for this screen
    private func setTexts() {
        self.title = TRStrings.profile.localizedString
        myCodeButton.setTitle(TRStrings.myCode.localizedString, for: .normal)
        if let items = tabBarController?.tabBar.items {
            items[0].title = TRStrings.home.localizedString
            items[1].title = TRStrings.user.localizedString
            items[2].title = TRStrings.tournaments.localizedString
        }
    }

    //sets data label texts
    private func setLabels() {
        userInfoView.setUser(user: preferences.user)
        userService.getSubsciptionsCount(uid: preferences.user.uid) { (num) in
            if let num = num {
                self.userInfoView.setSubscriptionsCount(count: num)
            }
        }
        userService.getSubscribersCount(uid: preferences.user.uid) { (num) in
            if let num = num {
                self.userInfoView.setSubscribersCount(count: num)
            }
        }
    }

    //sends user back to login screen
    private func userNotLogged() {
        self.presentAlertDelay(title: TRStrings.error.localizedString,
                               message: TRStrings.notLogged.localizedString,
                               delay: 2.0, completion: {
                                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        })
    }

    //loads user in preferences
    private func loadUserPref(uid: String) {
        let alert = loadingAlert()
        userService.getUserInfo(uid: uid) { (userData) in
            if let user = userData {
                self.preferences.user = user
                alert.dismiss(animated: true, completion: {
                    self.setLabels()
                })
            } else {
                alert.dismiss(animated: true, completion: {
                    self.presentAlert(title: TRStrings.error.localizedString,
                                      message: TRStrings.userNotRetrieved.localizedString)
                })
            }
        }
    }
}
