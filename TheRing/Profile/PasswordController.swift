//
//  PasswordController.swift
//  TheRing
//
//  Created by Kévin Courtois on 29/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class PasswordController: UIViewController {

    @IBOutlet weak var oldPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var oldPassLabel: UILabel!
    @IBOutlet weak var newPassLabel: UILabel!
    @IBOutlet weak var confirmPassLabel: UILabel!

    let preferences = Preferences()
    private var alert: UIAlertController?

    override func viewDidLoad() {
        //set texts for this screen
        setTexts()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
    }

    //set texts for this screen
    private func setTexts() {
        self.title = TRStrings.updatePassword.localizedString
        oldPassLabel.text = TRStrings.oldPassword.localizedString
        newPassLabel.text = TRStrings.newPassword.localizedString
        confirmPassLabel.text = TRStrings.confirmPass.localizedString
        oldPasswordField.placeholder = TRStrings.yourOldPassword.localizedString
        newPasswordField.placeholder = TRStrings.yourNewPassword.localizedString
        confirmField.placeholder = TRStrings.newPassConfirm.localizedString
    }

    @IBAction func saveTapped(_ sender: Any) {
        //show loading alert
        alert = loadingAlert()

        //get all fields to variables
        if let oldPwd = oldPasswordField.text, let newPwd = newPasswordField.text, let confirm = confirmField.text {
            if fieldsEmpty(oldPwd: oldPwd, newPwd: newPwd, confirm: confirm) {
                dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                            message: TRStrings.emptyFields.localizedString)
                return
            //check if new password matches confirm field
            } else if newPwd != confirm {
                dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                            message: TRStrings.confirmWrong.localizedString)
                return
            } else {
                //updates password
                updatePassword(oldPwd: oldPwd, newPwd: newPwd)
            }
        } else {
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                        message: TRStrings.errorOccured.localizedString)
        }
    }
}

// MARK: - Utilities
extension PasswordController {
    //Check if fields are empty or not
    private func fieldsEmpty(oldPwd: String, newPwd: String, confirm: String) -> Bool {
        return oldPwd.isEmpty || newPwd.isEmpty || confirm.isEmpty
    }
}

// MARK: - Network
extension PasswordController {
    //update user password
    private func updatePassword(oldPwd: String, newPwd: String) {
        FirebaseAuthService.updatePassword(oldPwd: oldPwd, newPwd: newPwd) { error in
            if let error = error {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                            message: error)
            } else {
                if let alert = self.alert {
                    alert.dismiss(animated: true) {
                        self.presentAlertPopRootVC(title: TRStrings.saved.localizedString,
                                                   message: TRStrings.modifSaved.localizedString)
                    }
                }
            }
        }
    }
}

// MARK: - Keyboard
extension PasswordController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        oldPasswordField.resignFirstResponder()
        newPasswordField.resignFirstResponder()
        confirmField.resignFirstResponder()
        return true
    }
}
