//
//  HomeController.swift
//  TheRing
//
//  Created by Kévin Courtois on 26/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeController: UIViewController {

    @IBOutlet weak var homeLabel: UILabel!
    private let preferences = Preferences()

    override func viewDidLoad() {
        super.viewDidLoad()
        setTexts()
        if let currUser = Auth.auth().currentUser {
            self.homeLabel.text = currUser.email
            if preferences.user.uid != currUser.uid {
                loadUserPref(uid: currUser.uid)
            }
        } else {
            userNotLogged()
        }
    }

    @IBAction func signOutTapped() {
        do {
            try Auth.auth().signOut()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        } catch {
            print("can't disconnect user")
        }
    }
}

// MARK: - UI & Preferences setup
extension HomeController {
    //sets label texts
    private func setTexts() {
        if let items = tabBarController?.tabBar.items {
            items[0].title = TRStrings.home.localizedString
            items[1].title = TRStrings.user.localizedString
            items[2].title = TRStrings.create.localizedString
        }
    }

    //sends user back to login screen
    private func userNotLogged() {
        presentAlertDelay(title: TRStrings.error.localizedString,
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
                alert.dismiss(animated: true, completion: nil)
            } else {
                alert.dismiss(animated: true, completion: {
                    self.presentAlert(title: TRStrings.error.localizedString,
                                      message: TRStrings.userNotRetrieved.localizedString)
                })
            }
        }
    }
}
