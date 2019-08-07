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
        //sets keyboard to dark theme
        descriptionField.keyboardAppearance = .dark
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //sets color for description field
        descriptionField.textColor = #colorLiteral(red: 0.5137254902, green: 0.5137254902, blue: 0.5137254902, alpha: 1)
        descriptionField.layer.borderColor = #colorLiteral(red: 0.5137254902, green: 0.5137254902, blue: 0.5137254902, alpha: 1)
        //set texts for this screen
        setTexts()
    }

    //adds tournament, and does a segue if it was created successfully
    @IBAction func nextTapped(_ sender: Any) {
        addTournament()
        if tournament != nil {
            performSegue(withIdentifier: "contestantSegue", sender: self)
        }
    }

    //gives tournament to next screen to continue the creation
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

    //creates tournament with this screen's data
    private func addTournament() {
        guard let title = titleField.text else {
            presentAlert(title: TRStrings.error.localizedString,
                         message: TRStrings.errorOccured.localizedString)
            return
        }

        //check if fields are not empty
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
    //set texts for this screen
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
