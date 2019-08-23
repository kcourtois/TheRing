//
//  EmailController.swift
//  TheRing
//
//  Created by Kévin Courtois on 29/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

//email controller handles email modification for the current user
class EmailController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var confirmEmailField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var newMailLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!

    private let emailModel = EmailModel(authService: FirebaseAuth(), userService: FirebaseUser())
    private let preferences = Preferences()
    private var alert: UIAlertController?

    override func viewDidLoad() {
        //set texts for this screen
        setTexts()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        //set observers on view appear
        super.viewWillAppear(animated)
        //set observers for notifications
        setObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //remove observers on view disappear
        NotificationCenter.default.removeObserver(self, name: .didRegisterUserInfo, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
    }

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didSendSubs
        NotificationCenter.default.addObserver(self, selector: #selector(onDidRegisterUserInfo),
                                               name: .didRegisterUserInfo, object: nil)
        //Notification observer for didSendError
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
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
            emailModel.updateEmail(password: password, mail: newMail, confirm: confirm)
        } else {
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                        message: TRStrings.errorOccured.localizedString)
        }
    }

    //Triggers on notification didRegisterUserInfo
    @objc private func onDidRegisterUserInfo(_ notification: Notification) {
        dismissAndSaveAlert()
    }

    //Triggers on notification didSendError
    @objc private func onDidSendError(_ notification: Notification) {
        if let data = notification.userInfo as? [String: String] {
            for (_, error) in data {
                dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                            message: error)
            }
        }
    }
}

// MARK: - Utilities
extension EmailController {
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

// MARK: - Keyboard
extension EmailController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordField.resignFirstResponder()
        newEmailField.resignFirstResponder()
        confirmEmailField.resignFirstResponder()
        return true
    }
}
