//
//  UserController.swift
//  TheRing
//
//  Created by Kévin Courtois on 26/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserController: UIViewController {

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var genderLabel: UITextField!
    @IBOutlet weak var biographyLabel: UITextField!
    @IBOutlet weak var mailLabel: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            getUserInfo(uid: user.uid)
        } else {
            print("no user connected")
        }
    }

    //get user info online
    private func getUserInfo(uid: String) {
        let reference = Database.database().reference()
        reference.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let user = User(username: value?["username"] as? String ?? "Unknown",
                            gender: value?["gender"] as? String ?? "Unknown",
                            email: value?["email"] as? String ?? "Unknown",
                            bio: value?["bio"] as? String ?? "Unknown")
            self.setLabels(user: user)
        })
    }

    private func setLabels(user: User) {
        mailLabel.text = user.email
        nameLabel.text = user.username
        genderLabel.text = user.gender
        biographyLabel.text = user.bio
    }
}
