//
//  LoginController.swift
//  TheRing
//
//  Created by Kévin Courtois on 22/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

//Controller for login screen, to log the user into the app
class LoginController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    private var alert: UIAlertController?

    private let loginModel = LoginModel(authService: FirebaseAuth())

    override func viewDidLoad() {
        super.viewDidLoad()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
        //set texts for this screen
        setTexts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set observers for notifications
        setObservers()
        //empty login fields
        emailField.text = ""
        passwordField.text = ""
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //remove observers on view disappear
        NotificationCenter.default.removeObserver(self, name: .didSignIn, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        //Skip login page if user signed
        if loginModel.alearyLogged() {
            signIn()
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

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didSignIn
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSignIn),
                                               name: .didSignIn, object: nil)
        //Notification observer for didSendError
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
    }

    @IBAction func loginTapped() {
        //Show a loading alert
        alert = loadingAlert()
        if let email = emailField.text, let password = passwordField.text {
            //Log the user in
            loginModel.signIn(email: email, password: password)
        } else {
            //Hide load alert and show error
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                        message: TRStrings.errorOccured.localizedString)
        }
    }

    //Triggers on notification didSignIn
    @objc private func onDidSignIn(_ notification: Notification) {
        signIn()
    }

    //Triggers on notification didSendError
    @objc private func onDidSendError(_ notification: Notification) {
        if let data = notification.userInfo as? [String: String] {
            for (_, error) in data {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                                 message: error)
            }
        }
    }

    private func signIn() {
        let signInModel = SigninModel(userService: FirebaseUser())
        signInModel.checkUserLogged { (error) in
            if error == nil {
                //when sign in notif recieved, perfom segue to log in
                if let alert = self.alert {
                    alert.dismiss(animated: true) {
                        self.performSegue(withIdentifier: "loginSegue", sender: self)
                    }
                } else {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            } else {
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
