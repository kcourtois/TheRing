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
        descriptionField.textColor = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1)
        descriptionField.layer.borderColor = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1)
        descriptionField.text = TRStrings.enterDescription.localizedString
    }

    @IBAction func nextTapped(_ sender: Any) {
        createTournament()
        if tournament != nil {
            performSegue(withIdentifier: "contestantSegue", sender: self)
        }
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

    private func createTournament() {
        guard let title = titleField.text else {
            presentAlert(title: TRStrings.error.localizedString,
                         message: TRStrings.errorOccured.localizedString)
            return
        }

        if title.isEmpty || descriptionField.text == TRStrings.enterDescription.localizedString {
            presentAlert(title: TRStrings.error.localizedString,
                         message: TRStrings.emptyFields.localizedString)
        }

        tournament = Tournament(title: title, description: descriptionField.text, contestants: [], endTime: Date())
    }
}

//Used to handle keyboard dismiss and create a placeholder
extension CreateTournamentController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1) {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = TRStrings.enterDescription.localizedString
            textView.textColor = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1)
        }
    }

    @IBAction func dismissKeyboard(_ sender: Any) {
        descriptionField.resignFirstResponder()
    }
}