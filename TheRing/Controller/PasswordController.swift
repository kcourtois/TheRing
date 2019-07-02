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

    let preferences = Preferences()
    private var alert: UIAlertController?

    @IBAction func saveTapped(_ sender: Any) {
        alert = loadingAlert()
        if let oldPwd = oldPasswordField.text, let newPwd = newPasswordField.text, let confirm = confirmField.text {
            if fieldsEmpty(oldPwd: oldPwd, newPwd: newPwd, confirm: confirm) {
                dismissAndLocalizedAlert(alert: alert, title: "Error",
                                            message: "Fields must not be empty.")
                return
            } else if newPwd != confirm {
                dismissAndLocalizedAlert(alert: alert, title: "Error",
                                            message: "Confirm field is wrong.")
                return
            } else {
                updatePassword(oldPwd: oldPwd, newPwd: newPwd)
            }
        } else {
            dismissAndLocalizedAlert(alert: self.alert, title: "Error",
                                     message: "An error occured. Please try again later.")
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
    private func updatePassword(oldPwd: String, newPwd: String) {
        FirebaseService.updatePassword(oldPwd: oldPwd, newPwd: newPwd) { error in
            if let error = error {
                self.dismissAndLocalizedAlert(alert: self.alert, title: "Error", message: error)
            } else {
                if let alert = self.alert {
                    alert.dismiss(animated: true) {
                        let saveAlertTitle = NSLocalizedString("Saved", comment: "Title for save alert")
                        let saveAlertMessage = NSLocalizedString("Your modifications were saved.",
                                                                 comment: "Message for save alert")
                        self.presentAlertPopRootVC(title: saveAlertTitle, message: saveAlertMessage)
                    }
                }
            }
        }
    }
}

// MARK: - Keyboard
extension PasswordController: UITextFieldDelegate {
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        oldPasswordField.resignFirstResponder()
        newPasswordField.resignFirstResponder()
        confirmField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        oldPasswordField.resignFirstResponder()
        newPasswordField.resignFirstResponder()
        confirmField.resignFirstResponder()
        return true
    }
}
