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

    private let preferences = Preferences()
    private let passwordModel: PasswordModel = PasswordModel(authService: FirebaseAuth())
    private var alert: UIAlertController?

    override func viewDidLoad() {
        //set texts for this screen
        setTexts()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set observers for notifications
        setObservers()
    }

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didUpdatePassword
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUpdatePassword),
                                               name: .didUpdatePassword, object: nil)
        //Notification observer for didSendError
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
    }

    //removes observers on deinit
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //remove observers on view disappear
        NotificationCenter.default.removeObserver(self, name: .didUpdatePassword, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
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
            //updates password
            passwordModel.updatePassword(oldPwd: oldPwd, newPwd: newPwd, confirm: confirm)
        } else {
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                        message: TRStrings.errorOccured.localizedString)
        }
    }

    //Triggers on notification didUpdatePassword
    @objc private func onDidUpdatePassword(_ notification: Notification) {
        if let alert = self.alert {
            alert.dismiss(animated: true) {
                self.presentAlertPopRootVC(title: TRStrings.saved.localizedString,
                                           message: TRStrings.modifSaved.localizedString)
            }
        }
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

// MARK: - Keyboard
extension PasswordController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        oldPasswordField.resignFirstResponder()
        newPasswordField.resignFirstResponder()
        confirmField.resignFirstResponder()
        return true
    }
}
