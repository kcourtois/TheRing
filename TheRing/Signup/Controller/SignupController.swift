//
//  SignupController.swift
//  TheRing
//
//  Created by Kévin Courtois on 22/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

//Signup controller, to create a new user account
class SignupController: UIViewController {
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!

    private var alert: UIAlertController?
    private let signupModel = SignupModel(authService: FirebaseAuth(), userService: FirebaseUser())

    override func viewDidLoad() {
        super.viewDidLoad()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
        //set texts for this screen
        setTexts()
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
        NotificationCenter.default.removeObserver(self, name: .didSignUp, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
    }

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didSignUp
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSignUp),
                                               name: .didSignUp, object: nil)
        //Notification observer for didSendError
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
    }

    //set texts for this screen
    private func setTexts() {
        descLabel.text = TRStrings.signUpDesc.localizedString
        emailField.placeholder = TRStrings.emailAddress.localizedString
        passwordField.placeholder = TRStrings.password.localizedString
        passwordConfirmField.placeholder = TRStrings.passwordConfirm.localizedString
        usernameField.placeholder = TRStrings.username.localizedString
        cancelButton.setTitle(TRStrings.cancel.localizedString, for: .normal)
        continueButton.setTitle(TRStrings.continueTxt.localizedString, for: .normal)
    }

    @IBAction func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func nextTapped(_ sender: Any) {
        //show loading alert
        alert = loadingAlert()
        signupModel.registerUser(email: emailField.text, password: passwordField.text,
                               confirm: passwordConfirmField.text, username: usernameField.text)
    }

    //When logged through signup, the user goes to user panel instead of home
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postSignupSegue", let tabBar = segue.destination as? UITabBarController {
            tabBar.selectedIndex = 1
        }
    }

    //Triggers on notification didSendError
    @objc private func onDidSendError(_ notification: Notification) {
        if let data = notification.userInfo as? [String: String] {
            for (_, error) in data {
                dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                            message: error)
            }
        }
    }

    //Triggers on notification didSignup
    @objc private func onDidSignUp(_ notification: Notification) {
        if let alert = self.alert {
            alert.dismiss(animated: true) {
                self.performSegue(withIdentifier: "postSignupSegue", sender: self)
            }
        } else {
            performSegue(withIdentifier: "postSignupSegue", sender: self)
        }
    }
}

// MARK: - Keyboard
extension SignupController: UITextFieldDelegate {
    //Textfield return hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        passwordConfirmField.resignFirstResponder()
        usernameField.resignFirstResponder()
        return true
    }
}
