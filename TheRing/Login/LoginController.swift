//
//  LoginController.swift
//  TheRing
//
//  Created by Kévin Courtois on 22/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    private var alert: UIAlertController?
    private let authService: AuthService = FirebaseAuth()

    override func viewDidLoad() {
        super.viewDidLoad()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
        //set texts for this screen
        setTexts()
        //Skip login page if user signed
        if authService.getLoggedUserUID() != nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
    }

    //set texts for this screen
    private func setTexts() {
        accountLabel.text = TRStrings.noAccount.localizedString
        signupButton.setTitle(TRStrings.signUp.localizedString, for: .normal)
        loginButton.setTitle(TRStrings.login.localizedString, for: .normal)
        emailField.placeholder = TRStrings.emailAddress.localizedString
        passwordField.placeholder = TRStrings.password.localizedString
    }

    @IBAction func loginTapped() {
        //Show a loading alert
        alert = loadingAlert()
        if let email = emailField.text, let password = passwordField.text {
            //Log the user in
            authService.signIn(email: email, password: password) { (error) in
                self.signInHandler(error: error)
            }
        } else {
            //Hide load alert and show error
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                        message: TRStrings.errorOccured.localizedString)
        }
    }

    private func signInHandler(error: String?) {
        if let error = error {
            self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                             message: error)
        } else {
            //If there was no error, perfom segue to log in
            if let alert = self.alert {
                alert.dismiss(animated: true) {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            } else {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
    }
}

// MARK: - Keyboard
extension LoginController: UITextFieldDelegate {
    //Textfield return hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return true
    }
}
