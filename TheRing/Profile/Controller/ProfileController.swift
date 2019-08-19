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

    private let profileModel = ProfileModel(userService: FirebaseUser())
    private let preferences = Preferences()
    private var alert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        //set texts for this screen
        setTexts()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
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
        NotificationCenter.default.removeObserver(self, name: .didRegisterUserInfo, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendSaveUser, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendUserInfo, object: nil)
    }

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didSendSubs
        NotificationCenter.default.addObserver(self, selector: #selector(onDidRegisterUserInfo),
                                               name: .didRegisterUserInfo, object: nil)
        //Notification observer for didSendError
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
        //Notification observer for didSendUserInfo
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendSaveUser),
                                               name: .didSendSaveUser, object: nil)
    }

    //set texts for this screen
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
                profileModel.checkUsernameAndSave(name: name)
            } else {
                //else, save
                saveUser()
            }
        } else {
            dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                                             message: TRStrings.errorOccured.localizedString)
        }
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

        profileModel.registerUserInfo(values: values)
    }

    //Triggers on notification didRegisterUserInfo
    @objc private func onDidRegisterUserInfo(_ notification: Notification) {
        savePreferences()
        dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.saved.localizedString,
                                    message: TRStrings.modifSaved.localizedString)
    }

    //Triggers on notification didSendSaveUser
    @objc private func onDidSendSaveUser(_ notification: Notification) {
        saveUser()
    }

    //Triggers on notification didSendError
    @objc private func onDidSendError(_ notification: Notification) {
        if let data = notification.userInfo as? [String: String] {
            for (_, error) in data {
                dismissLoadAlertWithMessage(alert: self.alert, title: TRStrings.error.localizedString,
                                            message: error)
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
