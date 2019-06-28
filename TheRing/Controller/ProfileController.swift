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
    @IBOutlet weak var mailTextField: UITextField!

    let preferences = Preferences()
    private var alert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setFields()
    }

    @IBAction func saveTapped(_ sender: Any) {
        if let name = nameTextField.text, let mail = mailTextField.text {
            if fieldsEmpty(name: name, mail: mail) {
                presentAlert(title: "Error", message: "Username and email must not be empty.")
                return
            } else if name != preferences.user.name {
                checkUsernameAndSave(name: name)
            } else {
                saveUser()
            }
        } else {
            presentAlert(title: "Error", message: "An error occured while saving your data.")
        }
    }

    private func setFields() {
        bioTextField.text = preferences.user.bio
        nameTextField.text = preferences.user.name
        mailTextField.text = preferences.user.email
        genderControl.selectedSegmentIndex = preferences.user.gender.rawValue
    }

    private func saveUser() {
        guard let bio = bioTextField.text, let name = nameTextField.text, let mail = mailTextField.text else {
            self.presentAlert(title: "Error", message: "An error occured. Please try again later.")
            return
        }

        let values = ["bio": bio,
                      "email": mail,
                      "gender": preferences.user.gender.rawValue,
                      "username": name] as [String: Any]

        FirebaseService.registerUserInfo(uid: preferences.user.uid, values: values) { (error) in
            if error != nil {
                self.presentAlert(title: "Error", message: "An error occured. Please try again later.")
            } else {
                self.savePreferences()
                self.presentAlertDelay(title: "Saved", message: "Your modifications were saved.",
                                       delay: 2, completion: {})
            }
        }
    }

    private func checkUsernameAndSave(name: String) {
        FirebaseService.isUsernameAvailable(name: name) { available in
            if available {
                self.replaceUsernameAndSave(name: name)
            } else {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: "Error",
                    message: "Username not available.")
                return
            }
        }
    }

    private func replaceUsernameAndSave(name: String) {
        FirebaseService.replaceUsername(old: self.preferences.user.name, new: name,
                                        uid: self.preferences.user.uid, completion: { (error) in
            if error == nil {
                self.saveUser()
            } else {
                self.dismissLoadAlertWithMessage(alert: self.alert, title: "Error",
                                                 message: "An error occured. Please try again later.")
            }
        })
    }

    private func savePreferences() {
        if let bio = bioTextField.text, let name = nameTextField.text, let mail = mailTextField.text {
            let user = User(uid: preferences.user.uid,
                            name: name,
                            gender: Gender(rawValue: genderControl.selectedSegmentIndex) ?? .other,
                            email: mail,
                            bio: bio)
            preferences.user = user
        }
    }

    private func fieldsEmpty(name: String, mail: String) -> Bool {
        return name.isEmpty || mail.isEmpty
    }
}
