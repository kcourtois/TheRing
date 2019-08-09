//
//  ProfileController.swift
//  TheRing
//
//  Created by Kévin Courtois on 27/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileController: UIViewController {
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var genderControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var modifyEmail: UIButton!
    @IBOutlet weak var modifyPassword: UIButton!
    @IBOutlet weak var logoutButton: UIButton!

    private let userService: UserService = FirebaseUser()
    private let preferences = Preferences()
    private var alert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        //set texts for this screen
        setTexts()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
    }

     //keyboard disappear after tap
    private func setTexts() {
        bioTextField.text = preferences.user.bio
        nameTextField.text = preferences.user.name
        genderControl.selectedSegmentIndex = preferences.user.gender.rawValue
        usernameLabel.text = TRStrings.username.localizedString
        genderLabel.text = TRStrings.gender.localizedString
        bioLabel.text = TRStrings.bio.localizedString
        emailLabel.text = TRStrings.email.localizedString
        passwordLabel.text = TRStrings.password.localizedString
        modifyEmail.setTitle(TRStrings.modEmail.localizedString, for: .normal)
        modifyPassword.setTitle(TRStrings.modPass.localizedString, for: .normal)
        nameTextField.placeholder = TRStrings.yourUsername.localizedString
        bioTextField.placeholder = TRStrings.yourBio.localizedString
        genderControl.setTitle(TRStrings.male.localizedString, forSegmentAt: 0)
        genderControl.setTitle(TRStrings.female.localizedString, forSegmentAt: 1)
        genderControl.setTitle(TRStrings.other.localizedString, forSegmentAt: 2)
        logoutButton.setTitle(TRStrings.logout.localizedString, for: .normal)
    }

    @IBAction func modifyEmailTapped() {
        performSegue(withIdentifier: "updateEmailSegue", sender: self)
    }

    @IBAction func modifyPasswordTapped() {
        performSegue(withIdentifier: "updatePasswordSegue", sender: self)
    }

    @IBAction func logoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        } catch {
            print("can't disconnect user")
        }
    }

    //Save profile update
    @IBAction func saveTapped(_ sender: Any) {
        //show loading alert
        alert = loadingAlert()
        if let name = nameTextField.text {
            if name.isEmpty {
                dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                                 message: TRStrings.emptyFields.localizedString)
                return
            } else if name != preferences.user.name {
                //if username changed, check if new one is available and save
                checkUsernameAndSave(name: name)
            } else {
                //else, save
                saveUser()
            }
        } else {
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                             message: TRStrings.errorOccured.localizedString)
        }
    }

    //save user to databse
    private func saveUser() {
        guard let bio = bioTextField.text, let name = nameTextField.text else {
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                        message: TRStrings.errorOccured.localizedString)
            return
        }

        let values = ["bio": bio,
                      "email": preferences.user.email,
                      "gender": genderControl.selectedSegmentIndex,
                      "username": name] as [String: Any]

        registerUserInfo(values: values)
    }

    //save user to preferences
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
    //replace username by new one, and save user to database
    private func replaceUsernameAndSave(name: String) {
        userService.replaceUsername(old: self.preferences.user.name, new: name,
                                        uid: self.preferences.user.uid, completion: { (error) in
            if error != nil {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                            message: TRStrings.errorOccured.localizedString)
            } else {
                self.saveUser()
            }
        })
    }

    //check if username is available, then save user to database
    private func checkUsernameAndSave(name: String) {
        userService.isUsernameAvailable(name: name) { available in
            if available {
                self.replaceUsernameAndSave(name: name)
            } else {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                            message: TRStrings.usernameUsed.localizedString)
                return
            }
        }
    }

    //save user to database
    private func registerUserInfo(values: [String: Any]) {
        userService.registerUserInfo(uid: preferences.user.uid, values: values) { (error) in
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bioTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        return true
    }
}
