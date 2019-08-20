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
    private let tournamentDateModel = TournamentDateModel(tournamentService: FirebaseTournament())

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var stepperRound: UIStepper!
    @IBOutlet weak var daysPerRound: UILabel!

    @IBOutlet weak var lastStepLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set observers for notifications
        setObservers()
        //set date picker min and max date
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        //set texts for this screen
        setTexts()
        //set days per round label
        updateDays(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //remove observers on view disappear
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didCreateTournament, object: nil)
    }

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didSendError
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
        //Notification observer for didCreateTournament
        NotificationCenter.default.addObserver(self, selector: #selector(onDidCreateTournament),
                                               name: .didCreateTournament, object: nil)
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
        if let tournament = tournament {
            tournamentDateModel.createTournament(tournament: tournament)
        } else {
            presentAlert(title: TRStrings.error.localizedString,
                         message: TRStrings.errorOccured.localizedString)
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

    //Triggers on notification didSendError
    @objc private func onDidSendError(_ notification: Notification) {
        if let data = notification.userInfo as? [String: String] {
            for (_, error) in data {
                presentAlert(title: TRStrings.error.localizedString, message: error)
            }
        }
    }

    //Triggers on notification didCreateTournament
    @objc private func onDidCreateTournament(_ notification: Notification) {
        presentAlertDelay(title: TRStrings.success.localizedString,
                               message: TRStrings.tournamentCreated.localizedString,
                               delay: 2, completion: {
            self.navigationController?.popToRootViewController(animated: false)
        })
    }
}
