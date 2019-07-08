//
//  CreateTournamentController.swift
//  TheRing
//
//  Created by Kévin Courtois on 08/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class CreateTournamentController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBAction func nextTapped(_ sender: Any) {
        performSegue(withIdentifier: "contestantSegue", sender: self)
    }
}
