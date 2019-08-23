//
//  PasswordModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 11/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

//model for password controller
class PasswordModel {
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    //update user password
    func updatePassword(oldPwd: String, newPwd: String, confirm: String) {
        if fieldsEmpty(oldPwd: oldPwd, newPwd: newPwd, confirm: confirm) {
            self.postErrorNotification(error: TRStrings.emptyFields.localizedString)
        } else if !confirmMatch(pass: newPwd, confirm: confirm) {
            self.postErrorNotification(error: TRStrings.confirmWrong.localizedString)
        } else {
            authService.updatePassword(oldPwd: oldPwd, newPwd: newPwd) { error in
                if let error = error {
                    self.postErrorNotification(error: error)
                } else {
                    self.postUpdatedPasswordNotification()
                }
            }
        }
    }

    //Check if fields are empty or not
    private func fieldsEmpty(oldPwd: String, newPwd: String, confirm: String) -> Bool {
        return oldPwd.isEmptyAfterTrim || newPwd.isEmptyAfterTrim || confirm.isEmptyAfterTrim
    }

    //returns true if confirm matches password
    private func confirmMatch(pass: String, confirm: String) -> Bool {
        return pass == confirm
    }

    //save user notification
    private func postUpdatedPasswordNotification() {
        NotificationCenter.default.post(name: .didUpdatePassword, object: nil,
                                        userInfo: [NotificationStrings.didUpdatePasswordKey:
                                            NotificationStrings.didUpdatePasswordKey])
    }

    //send error notification
    private func postErrorNotification(error: String) {
        NotificationCenter.default.post(name: .didSendError, object: nil,
                                        userInfo: [NotificationStrings.didSendErrorKey: error])
    }
}
