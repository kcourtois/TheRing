//
//  SignupModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 11/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class SignupModel {
    private let authService: AuthService
    private let userService: UserService
    private let preferences: Preferences

    init(authService: AuthService, userService: UserService, preferences: Preferences = Preferences()) {
        self.authService = authService
        self.userService = userService
        self.preferences = preferences
    }

    func registerUser(email: String?, password: String?, confirm: String?, username: String?) {
        //get all fields to text var
        guard let mail = email, let pass = password, let conf = confirm, let name = username else {
            postErrorNotification(error: TRStrings.errorOccured.localizedString)
            return
        }

        //check if fields are empty
        if mail.isEmptyAfterTrim || pass.isEmptyAfterTrim || conf.isEmptyAfterTrim || name.isEmptyAfterTrim {
            postErrorNotification(error: TRStrings.emptyFields.localizedString)
            return
        }

        //check if password == confirm
        if pass != conf {
            postErrorNotification(error: TRStrings.confirmWrong.localizedString)
            return
        }

        //Check if username is available
        usernameAvailable(username: name, email: mail, password: pass)
    }

    //Check if username is available
    private func usernameAvailable(username: String, email: String, password: String) {
        userService.isUsernameAvailable(name: username) { available in
            if available {
                self.createUser(email: email, password: password, username: username)
            } else {
                self.postErrorNotification(error: TRStrings.usernameUsed.localizedString)
                return
            }
        }
    }

    //Create user with all given parameters
    private func createUser(email: String, password: String, username: String) {
        //Create user in auth
        authService.createUser(email: email, password: password, username: username) { (uid, error) in
            if let error = error {
                self.postErrorNotification(error: error)
                return
            }

            guard let uid = uid else {
                self.postErrorNotification(error: TRStrings.errorOccured.localizedString)
                return
            }

            let values = ["email": email, "username": username,
                          "gender": Gender.other.rawValue, "bio": ""] as [String: Any]

            //register user data in firebase database
            self.registerUserInfo(uid: uid, username: username, values: values)
            //Store user in preferences
            Preferences().user = TRUser(uid: uid, name: username, gender: .other, email: email, bio: "")
        }
    }

    //register user data in firebase database
    private func registerUserInfo(uid: String, username: String, values: [String: Any]) {
        userService.registerUserInfo(uid: uid, values: values) { error in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.registerUsername(username: username, uid: uid)
            }
        }
    }

    //register username, which is used when checking if username is available
    private func registerUsername(username: String, uid: String) {
        userService.registerUsername(name: username, uid: uid) { error in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.postSignUpNotification()
            }
        }
    }

    //send error notification
    private func postErrorNotification(error: String) {
        NotificationCenter.default.post(name: .didSendError, object: nil,
                                        userInfo: [NotificationStrings.didSendErrorKey:
                                            error])
    }

    //send error notification
    private func postSignUpNotification() {
        NotificationCenter.default.post(name: .didSignUp, object: nil,
                                        userInfo: [NotificationStrings.didSignUpKey:
                                            NotificationStrings.didSignUpKey])
    }
}
