//
//  LoginController.swift
//  TheRing
//
//  Created by Kévin Courtois on 22/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    private var alert: UIAlertController?
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setTexts()
        //Skip login page if user signed in FOR TEST PURPOSES
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
    }

    private func setTexts() {
        accountLabel.text = TRStrings.noAccount.localizedString
        signupButton.setTitle(TRStrings.signUp.localizedString, for: .normal)
        loginButton.setTitle(TRStrings.login.localizedString, for: .normal)
        emailField.placeholder = TRStrings.emailAddress.localizedString
        passwordField.placeholder = TRStrings.password.localizedString
    }

    @IBAction func loginTapped() {
        alert = loadingAlert()
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
                self.signInHandler(error: error)
            }
        } else {
            dismissLoadAlertWithMessage(alert: alert, title: "Error",
                                        message: "An error occured, please try again later.")
        }
    }

    private func signInHandler(error: Error?) {
        if let error = error {
            guard let authError = AuthErrorCode(rawValue: error._code) else {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                                 message: TRStrings.errorOccured.localizedString)
                return
            }

            self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                             message: LocalizedString(key: authError.errorMessage).val )
        } else {
            if let alert = self.alert {
                alert.dismiss(animated: true) {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            }
        }
    }
}

// MARK: - Keyboard
extension LoginController: UITextFieldDelegate {
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return true
    }
}
