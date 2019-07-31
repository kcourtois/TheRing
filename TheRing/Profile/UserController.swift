//
//  UserController.swift
//  TheRing
//
//  Created by Kévin Courtois on 26/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import FirebaseAuth
import AVFoundation

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
    private var userType: UserListType = .subscriptions

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTexts()
        if let currUser = Auth.auth().currentUser {
            if preferences.user.uid != currUser.uid {
                loadUserPref(uid: currUser.uid)
            } else {
                self.setLabels()
            }
        } else {
            userNotLogged()
        }
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
        performSegue(withIdentifier: "showCodeSegue", sender: self)
    }

    @IBAction func scanCodeTapped(_ sender: Any) {
        proceedWithCameraAccess(identifier: "scannerSegue")
        //performSegue(withIdentifier: "scannerSegue", sender: self)
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
    //sets description label texts
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
        if let items = tabBarController?.tabBar.items {
            items[0].title = TRStrings.home.localizedString
            items[1].title = TRStrings.user.localizedString
            items[2].title = TRStrings.create.localizedString
        }
    }

    //sets data label texts
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
        UserService.getUserInfo(uid: uid) { (userData) in
            if let user = userData {
                self.preferences.user = user
                alert.dismiss(animated: true, completion: {
                    print(alert)
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

// MARK: - Camera permission
extension UserController {
    //ask permission for camera if not done, and perform segue
    func proceedWithCameraAccess(identifier: String) {
        AVCaptureDevice.requestAccess(for: .video) { success in
            if success {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: identifier, sender: nil)
                }
            } else {
                self.presentPermissionDeniedAlert()
            }
        }
    }

    //Shows a popup to access settings if user denied photolibrary permission
    private func presentPermissionDeniedAlert() {
        //Initialisation of the alert
        let alertController = UIAlertController(title: TRStrings.permissionDenied.localizedString,
                                                message: TRStrings.goToSettings.localizedString,
                                                preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: TRStrings.settings.localizedString, style: .default) { (_) -> Void in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (_) in })
                }
            }
        }
        let cancelAction = UIAlertAction(title: TRStrings.cancel.localizedString, style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        //Shows alert
        present(alertController, animated: true, completion: nil)
    }
}
