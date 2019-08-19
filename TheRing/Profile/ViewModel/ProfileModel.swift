//
//  ProfileModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 11/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class ProfileModel {
    private let userService: UserService
    private let preferences: Preferences

    init(userService: UserService, preferences: Preferences = Preferences()) {
        self.userService = userService
        self.preferences = preferences
    }

    ///check all preconditions before saving username
    func updateUsername(name: String) {
        if name.isEmptyAfterTrim {
            postErrorNotification(error: TRStrings.emptyFields.localizedString)
        } else if name != preferences.user.name {
            //if username changed, check if new one is available and save
            checkUsernameAndSave(name: name)
        } else {
            //else, save
            replaceUsernameAndSave(name: name)
        }
    }

    //check if username is available, and call replace & save
    private func checkUsernameAndSave(name: String) {
        userService.isUsernameAvailable(name: name) { available in
            if available {
                self.replaceUsernameAndSave(name: name)
            } else {
                self.postErrorNotification(error: TRStrings.usernameUsed.localizedString)
                return
            }
        }
    }

    //Register current user data
    func registerUserInfo(values: [String: Any]) {
        userService.registerUserInfo(uid: preferences.user.uid, values: values) { (error) in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.postRegisterUserInfoNotification()
            }
        }
    }

    //replace previous username by the one given as param
    private func replaceUsernameAndSave(name: String) {
        userService.replaceUsername(old: preferences.user.name, new: name,
                                    uid: preferences.user.uid, completion: { (error) in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.postSaveUserNotification()
            }
        })
    }

    //register user info notification
    private func postRegisterUserInfoNotification() {
        NotificationCenter.default.post(name: .didRegisterUserInfo, object: nil,
                                        userInfo: [NotificationStrings.didRegisterUserInfoKey:
                                                   NotificationStrings.didRegisterUserInfoKey])
    }

    //save user notification
    private func postSaveUserNotification() {
        NotificationCenter.default.post(name: .didSendSaveUser, object: nil,
                                        userInfo: [NotificationStrings.didSendSaveUserKey:
                                            NotificationStrings.didSendSaveUserKey])
    }

    //send error notification
    private func postErrorNotification(error: String) {
        NotificationCenter.default.post(name: .didSendError, object: nil,
                                        userInfo: [NotificationStrings.didSendErrorKey: error])
    }
}
