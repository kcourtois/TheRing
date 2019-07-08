//
//  ProfileController.swift
//  TheRing
//
//  Created by Kévin Courtois on 27/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var genderControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!

    let preferences = Preferences()
    private var alert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setFields()
    }

    @IBAction func modifyEmailTapped() {
        performSegue(withIdentifier: "updateEmailSegue", sender: self)
    }

    @IBAction func modifyPasswordTapped() {
        performSegue(withIdentifier: "updatePasswordSegue", sender: self)
    }

    @IBAction func saveTapped(_ sender: Any) {
        alert = loadingAlert()
        if let name = nameTextField.text {
            if name.isEmpty {
                dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                                 message: TRStrings.emptyFields.localizedString)
                return
            } else if name != preferences.user.name {
                checkUsernameAndSave(name: name)
            } else {
                saveUser()
            }
        } else {
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                             message: TRStrings.errorOccured.localizedString)
        }
    }

    private func setFields() {
        bioTextField.text = preferences.user.bio
        nameTextField.text = preferences.user.name
        genderControl.selectedSegmentIndex = preferences.user.gender.rawValue
    }

    private func saveUser() {
        guard let bio = bioTextField.text, let name = nameTextField.text else {
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                        message: TRStrings.errorOccured.localizedString)
            return
        }

        let values = ["bio": bio,
                      "email": preferences.user.email,
                      "gender": preferences.user.gender.rawValue,
                      "username": name] as [String: Any]

        registerUserInfo(values: values)
    }

    private func savePreferences() {
        if let bio = bioTextField.text, let name = nameTextField.text {
            let user = TRUser(uid: preferences.user.uid,
                            name: name,
                            gender: Gender(rawValue: genderControl.selectedSegmentIndex) ?? .other,
                            email: preferences.user.email,
                            bio: bio)
            preferences.user = user
        }
    }
}

// MARK: - Network
extension ProfileController {
    private func replaceUsernameAndSave(name: String) {
        FirebaseService.replaceUsername(old: self.preferences.user.name, new: name,
                                        uid: self.preferences.user.uid, completion: { (error) in
            if error != nil {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                            message: TRStrings.errorOccured.localizedString)
            } else {
                self.saveUser()
            }
        })
    }

    private func checkUsernameAndSave(name: String) {
        FirebaseService.isUsernameAvailable(name: name) { available in
            if available {
                self.replaceUsernameAndSave(name: name)
            } else {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                            message: TRStrings.usernameUsed.localizedString)
                return
            }
        }
    }

    private func registerUserInfo(values: [String: Any]) {
        FirebaseService.registerUserInfo(uid: preferences.user.uid, values: values) { (error) in
            if let error = error {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                                 message: error)
            } else {
                self.savePreferences()
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.saved.localizedString,
                                                 message: TRStrings.modifSaved.localizedString)
            }
        }
    }
}

// MARK: - Keyboard
extension ProfileController: UITextFieldDelegate {
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        bioTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bioTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        return true
    }
}
