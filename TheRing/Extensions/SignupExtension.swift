//
//  SignupExtension.swift
//  TheRing
//
//  Created by Kévin Courtois on 14/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

extension UIViewController {
    func checkUserLogged(preferences: Preferences = Preferences()) {
        let authService = FirebaseAuth()
        //Check if user logged
        if let uid = authService.getLoggedUserUID() {
            //Check if user pref are up to date
            if preferences.user.uid != uid {
                loadUserPref(uid: uid)
            }
        } else {
            userNotLogged()
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
    private func loadUserPref(uid: String, preferences: Preferences = Preferences()) {
        let alert = loadingAlert()
        let userService = FirebaseUser()
        userService.getUserInfo(uid: uid) { (userData) in
            if let user = userData {
                preferences.user = user
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
