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

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!

    let preferences = Preferences()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            FirebaseService.getUserInfo(uid: user.uid)
        } else {
            print("no user connected")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLabels()
    }

    private func setLabels() {
        mailLabel.text = preferences.user.email
        nameLabel.text = preferences.user.name
        genderLabel.text = preferences.user.gender.asString
        biographyLabel.text = preferences.user.bio
    }

    @IBAction func updateProfileTapped() {
        performSegue(withIdentifier: "profileSegue", sender: self)
    }

}
