//
//  LoginModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 11/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

//Model for LoginController
class LoginModel {
    private var authService: AuthService
    private var userService: UserService
    private var preferences: Preferences

    init(authService: AuthService, userService: UserService, preferences: Preferences = Preferences()) {
        self.authService = authService
        self.userService = userService
        self.preferences = preferences
    }

    //check if a user is aleady logged
    func alearyLogged() -> Bool {
        return authService.getLoggedUserUID() != nil
    }

    //try to sign in user with given credentials, and sends a notification for success or error
    func signIn(email: String, password: String) {
        authService.signIn(email: email, password: password) { (error) in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.postSignInNotification()
            }
        }
    }

    //check if a user is logged in, and load user in preferences if needed
    func checkUserLogged(completion: @escaping (String?) -> Void) {
        //Check if user logged
        if let uid = authService.getLoggedUserUID() {
            //Check if user pref are up to date
            if preferences.user.uid != uid {
                loadUserPref(uid: uid) { (result) in
                    completion(result)
                }
            } else {
                completion(nil)
            }
        } else {
            completion(TRStrings.userNotRetrieved.localizedString)
        }
    }

    //loads user in preferences
    private func loadUserPref(uid: String, completion: @escaping (String?) -> Void) {
        userService.getUserInfo(uid: uid) { (userData) in
            if let user = userData {
                self.preferences.user = user
                completion(nil)
            } else {
                completion(TRStrings.userNotRetrieved.localizedString)
            }
        }
    }

    //send sign in notification
    private func postSignInNotification() {
        NotificationCenter.default.post(name: .didSignIn, object: nil,
                                        userInfo: [NotificationStrings.didSignInKey:
                                            NotificationStrings.didSignInKey])
    }

    //send error notification
    private func postErrorNotification(error: String) {
        NotificationCenter.default.post(name: .didSendError, object: nil,
                                        userInfo: [NotificationStrings.didSendErrorKey: error])
    }
}
