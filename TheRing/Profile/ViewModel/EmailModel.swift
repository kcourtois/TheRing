//
//  EmailModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 11/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class EmailModel {
    private let authService: AuthService
    private let userService: UserService
    private let preferences: Preferences

    init(authService: AuthService, userService: UserService, preferences: Preferences = Preferences()) {
        self.authService = authService
        self.userService = userService
        self.preferences = preferences
    }

    //check all preconditions before saving new email
    func updateEmail(password: String, mail: String, confirm: String) {
        if fieldsEmpty(password: password, mail: mail, confirm: confirm) {
            postErrorNotification(error: TRStrings.emptyFields.localizedString)
        } else if !differentMail(old: preferences.user.email, new: mail) {
            postErrorNotification(error: TRStrings.mailSelfUse.localizedString)
        } else if !confirmMatch(email: mail, confirm: confirm) {
            postErrorNotification(error: TRStrings.confirmWrong.localizedString)
        } else {
            updateMailAndSave(password: password, mail: mail)
        }
    }

    //Check if fields are empty or not
    private func fieldsEmpty(password: String, mail: String, confirm: String) -> Bool {
        return password.isEmptyAfterTrim || mail.isEmptyAfterTrim || confirm.isEmptyAfterTrim
    }

    //returns true if confirm matches email
    private func confirmMatch(email: String, confirm: String) -> Bool {
        return email == confirm
    }

    //check if new mail is not equal to old one
    private func differentMail(old: String, new: String) -> Bool {
        return old != new
    }

    //updates email and saves user
    private func updateMailAndSave(password: String, mail: String) {
        authService.updateEmail(password: password, mail: mail) { error in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.saveUser(mail: mail)
            }
        }
    }

    //save user to update with provided email
    private func saveUser(mail: String) {
        let values = ["bio": preferences.user.bio,
                      "email": mail,
                      "gender": preferences.user.gender.rawValue,
                      "username": preferences.user.name] as [String: Any]

        userService.registerUserInfo(uid: preferences.user.uid, values: values) { (error) in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.savePreferences(mail: mail)
                self.postRegisterUserInfoNotification()
            }
        }
    }

    //save new email to preferences
    private func savePreferences(mail: String) {
        let user = TRUser(uid: preferences.user.uid,
                          name: preferences.user.name,
                          gender: preferences.user.gender,
                          email: mail,
                          bio: preferences.user.bio)
        preferences.user = user
    }

    //register user info notification
    private func postRegisterUserInfoNotification() {
        NotificationCenter.default.post(name: .didRegisterUserInfo, object: nil,
                                        userInfo: [NotificationStrings.didRegisterUserInfoKey:
                                            NotificationStrings.didRegisterUserInfoKey])
    }

    //send error notification
    private func postErrorNotification(error: String) {
        NotificationCenter.default.post(name: .didSendError, object: nil,
                                        userInfo: [NotificationStrings.didSendErrorKey: error])
    }
}
