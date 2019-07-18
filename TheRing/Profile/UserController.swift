//
//  UserController.swift
//  TheRing
//
//  Created by Kévin Courtois on 26/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserController: UIViewController {

    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var usernameDesc: UILabel!
    @IBOutlet weak var emailDesc: UILabel!
    @IBOutlet weak var genderDesc: UILabel!
    @IBOutlet weak var bioDesc: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var tournamentsLabel: UILabel!
    @IBOutlet weak var tournamentsButton: UIButton!

    private let preferences = Preferences()
    private var alert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setTexts()
        alert = loadingAlert()
        if let user = Auth.auth().currentUser {
            FirebaseService.getUserInfo(uid: user.uid, completion: { user in
                if let user = user {
                    self.preferences.user = user
                    self.setLabels()
                    if let alert = self.alert {
                        alert.dismiss(animated: true, completion: nil)
                    }
                } else {
                    print("no user retrieved")
                    if let alert = self.alert {
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
            })
        } else {
            print("no user connected")
            if let alert = self.alert {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLabels()
    }

    @IBAction func seeTournaments(_ sender: Any) {
        performSegue(withIdentifier: "TournamentListSegue", sender: self)
    }

    @IBAction func updateProfileTapped() {
        performSegue(withIdentifier: "profileSegue", sender: self)
    }

    private func setLabels() {
        mailLabel.text = preferences.user.email
        nameLabel.text = preferences.user.name
        genderLabel.text = preferences.user.gender.asString
        biographyLabel.text = preferences.user.bio
    }

    private func setTexts() {
        profileLabel.text = TRStrings.profile.localizedString
        usernameDesc.text = TRStrings.username.localizedString
        emailDesc.text = TRStrings.email.localizedString
        genderDesc.text = TRStrings.gender.localizedString
        bioDesc.text = TRStrings.bio.localizedString
        updateButton.setTitle(TRStrings.updateProfile.localizedString, for: .normal)
        tournamentsLabel.text = TRStrings.tournaments.localizedString
        tournamentsButton.setTitle(TRStrings.seeTournaments.localizedString, for: .normal)
    }

}
