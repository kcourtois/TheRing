//
//  CreateTournamentController.swift
//  TheRing
//
//  Created by Kévin Courtois on 08/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateTournamentController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    private let preferences = Preferences()
    var tournament: Tournament?

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionField.keyboardAppearance = .dark
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        descriptionField.textColor = #colorLiteral(red: 0.5137254902, green: 0.5137254902, blue: 0.5137254902, alpha: 1)
        descriptionField.layer.borderColor = #colorLiteral(red: 0.5137254902, green: 0.5137254902, blue: 0.5137254902, alpha: 1)
        setTexts()
    }

    @IBAction func nextTapped(_ sender: Any) {
        addTournament()
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

    private func addTournament() {
        guard let title = titleField.text else {
            presentAlert(title: TRStrings.error.localizedString,
                         message: TRStrings.errorOccured.localizedString)
            return
        }

        if title.isEmpty || descriptionField.text == TRStrings.enterDescription.localizedString {
            presentAlert(title: TRStrings.error.localizedString,
                         message: TRStrings.emptyFields.localizedString)
        }

        tournament = Tournament(tid: "", title: title, description: descriptionField.text, contestants: [],
                                startTime: Date(), roundDuration: 1, creator: preferences.user.uid)
    }
}

// MARK: - UI & Preferences setup
extension CreateTournamentController {
    //sets label texts
    private func setTexts() {
        descriptionField.text = TRStrings.enterDescription.localizedString
        titleField.placeholder = TRStrings.enterTitle.localizedString
        titleField.text = ""
        titleLabel.text = TRStrings.title.localizedString
        self.title = TRStrings.createTournaments.localizedString
        nextButton.setTitle(TRStrings.next.localizedString, for: .normal)
    }
}

// MARK: - Keyboard dismiss and placeholders setup
extension CreateTournamentController: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == #colorLiteral(red: 0.5137254902, green: 0.5137254902, blue: 0.5137254902, alpha: 1) {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = TRStrings.enterDescription.localizedString
            textView.textColor = #colorLiteral(red: 0.5137254902, green: 0.5137254902, blue: 0.5137254902, alpha: 1)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
