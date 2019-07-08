//
//  SelectContestantController.swift
//  TheRing
//
//  Created by Kévin Courtois on 08/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class SelectContestantController: UIViewController {

    @IBOutlet weak var contestantView: UIView!

    @IBAction func pickTapped(_ sender: Any) {
        performSegue(withIdentifier: "contestantPickerSegue", sender: self)
    }

    @IBAction func nextTapped(_ sender: Any) {
        performSegue(withIdentifier: "datepickSegue", sender: self)
    }
}
