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

        isUsernameAvailable(username: username) { available in
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

            self.registerUserInfo(uid: uid, values: values) { error in
                if let error = error {
                    self.dismissLoadAlertWithMessage(alert: self.alert, title: "Error", message: "\(error)")
                } else {
                    self.registerUsername(username: username, uid: uid) { error in
                        if let error = error {
                            self.dismissLoadAlertWithMessage(alert: self.alert, title: "Error", message: "\(error)")
                        } else {
                            self.presentAlertDelay(title: "Success",
                                                   message: "Your account was created successfully.", delay: 2) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - FireBase Calls
extension SignupController {
    //check if username is available or aleardy used
    private func isUsernameAvailable(username: String, completion: @escaping (Bool) -> Void) {
        let reference = Database.database().reference()
        reference.child("usernames").child(username).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                completion(false)
            } else {
                completion(true)
            }
        }, withCancel: nil)
    }

    //register user informations such as username, gender, bio...
    private func registerUserInfo(uid: String, values: [String: String], completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("users").child(uid).updateChildValues(values,
                                                              withCompletionBlock: { (error, _) in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            completion(nil)
        })
    }

    //register username for future use
    private func registerUsername(username: String, uid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("usernames").updateChildValues([username: uid], withCompletionBlock: { (error, _) in
            if let error = error {
                completion(error.localizedDescription)
            }
            completion(nil)
        })
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
