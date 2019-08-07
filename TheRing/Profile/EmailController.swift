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
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var newMailLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!

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
        self.title = TRStrings.updateEmail.localizedString
        passwordLabel.text = TRStrings.password.localizedString
        newMailLabel.text = TRStrings.newMail.localizedString
        confirmLabel.text = TRStrings.confirmMail.localizedString
        passwordField.placeholder = TRStrings.yourPassword.localizedString
        newEmailField.placeholder = TRStrings.yourNewMail.localizedString
        confirmEmailField.placeholder = TRStrings.newEmailConfirm.localizedString
    }

    @IBAction func saveTapped(_ sender: Any) {
        //show loading alert
        alert = loadingAlert()

        //get all fields to variables
        if let password = passwordField.text, let newMail = newEmailField.text, let confirm = confirmEmailField.text {
            if fieldsEmpty(password: password, mail: newMail, confirm: confirm) {
                dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                            message: TRStrings.emptyFields.localizedString)
                return
            //check if new mail is not equal to old one
            } else if newMail == preferences.user.email {
                dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                            message: TRStrings.mailSelfUse.localizedString)
                return
            //check if new mail matches confirm field
            } else if newMail != confirm {
                dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                            message: TRStrings.confirmWrong.localizedString)
                return
            } else {
                //update mail
                updateMailAndSave(password: password, mail: newMail)
            }
        } else {
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                        message: TRStrings.errorOccured.localizedString)
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
                self.presentAlertPopRootVC(title: TRStrings.saved.localizedString,
                                           message: TRStrings.modifSaved.localizedString)
            }
        }
    }
}

// MARK: - Network
extension EmailController {
    //save user to update with provided email
    private func saveUser(mail: String) {
        let values = ["bio": preferences.user.bio,
                      "email": mail,
                      "gender": preferences.user.gender.rawValue,
                      "username": preferences.user.name] as [String: Any]

        UserService.registerUserInfo(uid: preferences.user.uid, values: values) { (error) in
            if let error = error {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                            message: error)
            } else {
                self.savePreferences(mail: mail)
                self.dismissAndSaveAlert()
            }
        }
    }

    //updates email and saves user
    private func updateMailAndSave(password: String, mail: String) {
        FirebaseAuthService.updateEmail(password: password, mail: mail) { error in
            if let error = error {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                                 message: error)
            } else {
                self.saveUser(mail: mail)
            }
        }
    }
}

// MARK: - Keyboard
extension EmailController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordField.resignFirstResponder()
        newEmailField.resignFirstResponder()
        confirmEmailField.resignFirstResponder()
        return true
    }
}
