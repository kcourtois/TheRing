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
    private let tournamentService: TournamentService = FirebaseTournament()

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var stepperRound: UIStepper!
    @IBOutlet weak var daysPerRound: UILabel!

    @IBOutlet weak var lastStepLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!

    override func viewDidLoad() {
        //set date picker min and max date
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        //set texts for this screen
        setTexts()
        //set days per round label
        updateDays(self)
    }

    //set texts for this screen
    private func setTexts() {
        self.title = TRStrings.createTournaments.localizedString
        lastStepLabel.text = TRStrings.lastStep.localizedString
        startTimeLabel.text = TRStrings.startTime.localizedString
    }

    //set days per round label
    @IBAction func updateDays(_ sender: Any) {
        daysPerRound.text = "\(TRStrings.roundDays.localizedString): \(Int(stepperRound.value))"
    }

    //create tournament in DB and pop to root view
    @IBAction func doneTapped(_ sender: Any) {
        updateTournament()
        if let tournament = tournament { //Put var instead of let
            //tournament.startTime = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            tournamentService.createTournament(tournament: tournament) { (error) in
                if let error = error {
                    self.presentAlert(title: TRStrings.error.localizedString, message: error)
                } else {
                    self.presentAlertDelay(title: TRStrings.success.localizedString,
                                           message: TRStrings.tournamentCreated.localizedString,
                                           delay: 2, completion: {
                        self.navigationController?.popToRootViewController(animated: false)
                    })
                }
            }
        }
    }

    //set round duration and start time for tournament
    private func updateTournament() {
        if var tournament = tournament {
            tournament.roundDuration = Int(stepperRound.value)
            tournament.startTime = datePicker.date
            self.tournament = tournament
        }
    }
}
