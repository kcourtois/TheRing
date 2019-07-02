//
//  EmailController.swift
//  TheRing
//
//  Created by Kévin Courtois on 29/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class EmailController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var confirmEmailField: UITextField!

    let preferences = Preferences()
    private var alert: UIAlertController?

    @IBAction func saveTapped(_ sender: Any) {
        alert = loadingAlert()
        if let password = passwordField.text, let newMail = newEmailField.text, let confirm = confirmEmailField.text {
            if fieldsEmpty(password: password, mail: newMail, confirm: confirm) {
                dismissAndLocalizedAlert(alert: alert, title: "Error", message: "Fields must not be empty.")
                return
            } else if newMail == preferences.user.email {
                dismissAndLocalizedAlert(alert: alert, title: "Error", message: "You already use this email.")
                return
            } else if newMail != confirm {
                dismissAndLocalizedAlert(alert: alert, title: "Error", message: "Confirm field is wrong.")
                return
            } else {
                updateMailAndSave(password: password, mail: newMail)
            }
        } else {
            dismissAndLocalizedAlert(alert: self.alert, title: "Error",
                                     message: "An error occured. Please try again later.")
        }
    }
}

// MARK: - Utilities
extension EmailController {
    private func savePreferences(mail: String) {
        let user = TRUser(uid: preferences.user.uid,
                          name: preferences.user.name,
                          gender: preferences.user.gender,
                          email: mail,
                          bio: preferences.user.bio)
        preferences.user = user
    }

    //Check if fields are empty or not
    private func fieldsEmpty(password: String, mail: String, confirm: String) -> Bool {
        return password.isEmpty || mail.isEmpty || confirm.isEmpty
    }

    //Dismiss loading alert and show save message
    private func dismissAndSaveAlert() {
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

// MARK: - Network
extension EmailController {
    private func saveUser(mail: String) {
        let values = ["bio": preferences.user.bio,
                      "email": mail,
                      "gender": preferences.user.gender.rawValue,
                      "username": preferences.user.name] as [String: Any]

        FirebaseService.registerUserInfo(uid: preferences.user.uid, values: values) { (error) in
            if let error = error {
                self.dismissAndLocalizedAlert(alert: self.alert, title: "Error", message: error)
            } else {
                self.savePreferences(mail: mail)
                self.dismissAndSaveAlert()
            }
        }
    }

    private func updateMailAndSave(password: String, mail: String) {
        FirebaseService.updateEmail(password: password, mail: mail) { error in
            if let error = error {
                self.dismissAndLocalizedAlert(alert: self.alert, title: "Error", message: error)
            } else {
                self.saveUser(mail: mail)
            }
        }
    }
}

// MARK: - Keyboard
extension EmailController: UITextFieldDelegate {
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        passwordField.resignFirstResponder()
        newEmailField.resignFirstResponder()
        confirmEmailField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordField.resignFirstResponder()
        newEmailField.resignFirstResponder()
        confirmEmailField.resignFirstResponder()
        return true
    }
}
