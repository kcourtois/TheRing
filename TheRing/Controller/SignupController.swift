//
//  SignupController.swift
//  TheRing
//
//  Created by Kévin Courtois on 22/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignupController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    private var alert: UIAlertController?
    private let tabIndex = 1

    @IBAction func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func nextTapped(_ sender: Any) {
        alert = loadingAlert()

        guard let email = emailField.text, let password = passwordField.text,
            let confirm = passwordConfirmField.text, let username = usernameField.text else {
                dismissAndLocalizedAlert(alert: alert, title: "Error",
                                            message: "An error occured. Please try again later.")
                return
        }

        if (email == "") || (password == "") || (confirm == "") || (username == "") {
            dismissAndLocalizedAlert(alert: alert, title: "Error",
                                        message: "Fields must not be empty.")
            return
        }

        if password != confirm {
            dismissAndLocalizedAlert(alert: alert, title: "Error", message: "Confirm field is wrong.")
            return
        }

        FirebaseService.isUsernameAvailable(name: username) { available in
            if available {
                self.createUser(email: email, password: password, username: username)
            } else {
                self.dismissAndLocalizedAlert(alert: self.alert, title: "Error", message: "Username not available.")
                return
            }
        }
    }

    private func createUser(email: String, password: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                if let authError = AuthErrorCode(rawValue: error._code) {
                    self.dismissAndLocalizedAlert(alert: self.alert, title: "Error",
                                                  message: authError.errorMessage)
                }
                self.dismissAndLocalizedAlert(alert: self.alert, title: "Error",
                                                 message: "An error occured. Please try again later.")
                return
            }

            guard let uid = result?.user.uid else {
                return
            }

            let values = ["email": email, "username": username, "gender": "unknown", "bio": ""]

            FirebaseService.registerUserInfo(uid: uid, values: values) { error in
                if let error = error {
                    self.dismissAndLocalizedAlert(alert: self.alert, title: "Error", message: error)
                } else {
                    FirebaseService.registerUsername(name: username, uid: uid) { error in
                        if let error = error {
                            self.dismissAndLocalizedAlert(alert: self.alert, title: "Error", message: error)
                        } else {
                            if let alert = self.alert {
                                alert.dismiss(animated: true) {
                                    self.performSegue(withIdentifier: "postSignupSegue", sender: self)
                                }
                            } else {
                                self.performSegue(withIdentifier: "postSignupSegue", sender: self)
                            }
                        }
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postSignupSegue", let tabBar = segue.destination as? UITabBarController {
            tabBar.selectedIndex = tabIndex
        }
    }
}

// MARK: - Keyboard
extension SignupController: UITextFieldDelegate {
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        passwordConfirmField.resignFirstResponder()
        usernameField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        passwordConfirmField.resignFirstResponder()
        usernameField.resignFirstResponder()
        return true
    }
}
