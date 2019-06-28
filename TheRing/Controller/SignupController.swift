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
                dismissLoadAlertWithMessage(alert: alert, title: "Error",
                                            message: "An error occured. Please try again later.")
                return
        }

        if (email == "") || (password == "") || (confirm == "") || (username == "") {
            dismissLoadAlertWithMessage(alert: alert, title: "Error",
                                        message: "Please make sure to fill all the fields.")
            return
        }

        if password != confirm {
            dismissLoadAlertWithMessage(alert: alert, title: "Error", message: "Password doesn't match.")
            return
        }

        FirebaseService.isUsernameAvailable(name: username) { available in
            if available {
                self.createUser(email: email, password: password, username: username)
            } else {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: "Error", message: "Username not available.")
                return
            }
        }
    }

    private func createUser(email: String, password: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: "Error",
                                                 message: "\(error.localizedDescription)")
                return
            }

            guard let uid = result?.user.uid else {
                return
            }

            let values = ["email": email, "username": username, "gender": "unknown", "bio": ""]

            FirebaseService.registerUserInfo(uid: uid, values: values) { error in
                if let error = error {
                    self.dismissLoadAlertWithMessage(alert: self.alert, title: "Error", message: "\(error)")
                } else {
                    FirebaseService.registerUsername(name: username, uid: uid) { error in
                        if let error = error {
                            self.dismissLoadAlertWithMessage(alert: self.alert, title: "Error", message: "\(error)")
                        } else {
                            if let alert = self.alert {
                                alert.dismiss(animated: true) {
                                    self.presentAlertDelay(title: "Success",
                                                           message: "Your account was created successfully.", delay: 2) {
                                                            self.performSegue(withIdentifier: "postSignupSegue", sender: self)
                                    }
                                }
                            } else {
                                self.presentAlertDelay(title: "Success",
                                                       message: "Your account was created successfully.", delay: 2) {
                                                        self.performSegue(withIdentifier: "postSignupSegue", sender: self)
                                }
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
