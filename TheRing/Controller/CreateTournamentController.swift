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

    var tournament: Tournament?

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionField.textColor = UIColor.lightGray
        descriptionField.layer.borderColor = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1)
        descriptionField.text = TRStrings.enterDescription.localizedString
    }

    @IBAction func nextTapped(_ sender: Any) {
        performSegue(withIdentifier: "contestantSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contestantSegue",
            let selectContestantVC = segue.destination as? SelectContestantController {
            if let tournament = tournament {
                selectContestantVC.tournament = tournament
            } else {
                return
            }
        }
    }
}

//Used to handle keyboard dismiss and create a placeholder
extension CreateTournamentController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = TRStrings.enterDescription.localizedString
            textView.textColor = UIColor.lightGray
        }
    }

    @IBAction func dismissKeyboard(_ sender: Any) {
        descriptionField.resignFirstResponder()
    }
}
