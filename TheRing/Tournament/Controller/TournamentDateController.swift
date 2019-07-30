//
//  TournamentDateController.swift
//  TheRing
//
//  Created by Kévin Courtois on 08/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class TournamentDateController: UIViewController {

    var tournament: Tournament?
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var stepperRound: UIStepper!
    @IBOutlet weak var daysPerRound: UILabel!

    @IBOutlet weak var lastStepLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!

    override func viewDidLoad() {
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        setTexts()
        updateDays(self)
    }

    private func setTexts() {
        self.title = TRStrings.createTournaments.localizedString
        lastStepLabel.text = TRStrings.lastStep.localizedString
        startTimeLabel.text = TRStrings.startTime.localizedString
    }

    @IBAction func updateDays(_ sender: Any) {
        daysPerRound.text = "\(TRStrings.roundDays.localizedString): \(Int(stepperRound.value))"
    }

    @IBAction func doneTapped(_ sender: Any) {
        updateTournament()
        if var tournament = tournament { //Put let instead of var
            //remove next line
            //tournament.startTime = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            TournamentService.createTournament(tournament: tournament) { (error) in
                if let error = error {
                    self.presentAlert(title: "Test", message: error)
                } else {
                    print("MEYDEN")
                }
            }
        }
    }

    private func updateTournament() {
        if var tournament = tournament {
            tournament.roundDuration = Int(stepperRound.value)
            tournament.startTime = datePicker.date
            self.tournament = tournament
        }
    }
}
