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

    override func viewDidLoad() {
        super.viewDidLoad()
        //Skip login page if user signed in FOR TEST PURPOSES
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
                print("hi")
            }
        }
    }

    @IBAction func loginTapped() {
        alert = loadingAlert()
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
                if let error = error {
                    self.dismissLoadAlertWithMessage(alert: self.alert, title: "Error",
                                                     message: "\(error.localizedDescription)")
                    return
                } else {
                    if let alert = self.alert {
                        alert.dismiss(animated: true) {
                            self.performSegue(withIdentifier: "loginSegue", sender: self)
                        }
                    }
                }
            }
        } else {
            dismissLoadAlertWithMessage(alert: alert, title: "Error",
                                        message: "An error occured, please try again later.")
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
