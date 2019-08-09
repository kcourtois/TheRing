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
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!

    private var alert: UIAlertController?
    private let userService: UserService = FirebaseUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
        //set texts for this screen
        setTexts()
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

        //get all fields to text var
        guard let email = emailField.text, let password = passwordField.text,
            let confirm = passwordConfirmField.text, let username = usernameField.text else {
                dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                                 message: TRStrings.errorOccured.localizedString)
                return
        }

        //check if fields are empty
        if email.isEmpty || password.isEmpty || confirm.isEmpty || username.isEmpty {
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                        message: TRStrings.emptyFields.localizedString)
            return
        }

        //check if password == confirm
        if password != confirm {
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                        message: TRStrings.confirmWrong.localizedString)
            return
        }

        //Check if username is available
        usernameAvailable(username: username, email: email, password: password)
    }

    //Check if username is available
    private func usernameAvailable(username: String, email: String, password: String) {
        userService.isUsernameAvailable(name: username) { available in
            if available {
                self.createUser(email: email, password: password, username: username)
            } else {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                            message: TRStrings.usernameUsed.localizedString)
                return
            }
        }
    }

    //Create user with all given parameters
    private func createUser(email: String, password: String, username: String) {
        //Create user in firebase auth
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                if let authError = AuthErrorCode(rawValue: error._code) {
                    self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                                     message: LocalizedString(key: authError.errorMessage).val )
                } else {
                    self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                                     message: TRStrings.errorOccured.localizedString)
                }
                return
            }

            guard let uid = result?.user.uid else {
                return
            }

            let values = ["email": email, "username": username,
                          "gender": Gender.other.rawValue, "bio": ""] as [String: Any]

            //register user data in firebase database
            self.registerUserInfo(uid: uid, username: username, values: values)
            //Store user in preferences
            Preferences().user = TRUser(uid: uid, name: username, gender: .other, email: email, bio: "")
        }
    }

    //register user data in firebase database
    private func registerUserInfo(uid: String, username: String, values: [String: Any]) {
        userService.registerUserInfo(uid: uid, values: values) { error in
            if let error = error {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                                 message: error)
            } else {
                self.registerUsername(username: username, uid: uid)
            }
        }
    }

    //register username, which is used when checking if username is available
    private func registerUsername(username: String, uid: String) {
        userService.registerUsername(name: username, uid: uid) { error in
            if let error = error {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                                 message: error)
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

    //When logged through signup, the user goes to user panel instead of home
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postSignupSegue", let tabBar = segue.destination as? UITabBarController {
            tabBar.selectedIndex = 1
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
