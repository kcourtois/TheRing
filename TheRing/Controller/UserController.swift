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

    private let preferences = Preferences()
    private var alert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
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
