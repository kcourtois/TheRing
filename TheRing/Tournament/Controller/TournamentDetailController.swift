//
//  TournamentDetailController.swift
//  TheRing
//
//  Created by Kévin Courtois on 18/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class TournamentDetailController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var titleDataLabel: UILabel!
    @IBOutlet weak var descDataLabel: UILabel!
    @IBOutlet weak var startTimeDataLabel: UILabel!
    @IBOutlet weak var creatorDataLabel: UILabel!
    @IBOutlet weak var tournamentLabel: UILabel!
    @IBOutlet weak var tournamentView: TournamentView!

    var tid: String?
    var tournament: TournamentData?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tid = tid {
            TournamentService.getTournamentFull(tid: tid) { (tournament) in
                self.tournament = tournament
                if self.tournament != nil {
                    self.setTexts()
                    self.tournamentView.setView(tournament: tournament)
                } else {
                    self.presentAlertPopRootVC(title: TRStrings.error.localizedString,
                                               message: TRStrings.errorCreator.localizedString)
                }
            }
        } else {
            presentAlertPopRootVC(title: TRStrings.error.localizedString,
                                  message: TRStrings.errorCreator.localizedString)
        }
    }

    private func setTexts() {
        titleLabel.text = TRStrings.title.localizedString
        startTimeLabel.text = TRStrings.startTime.localizedString
        creatorLabel.text = TRStrings.creator.localizedString
        tournamentLabel.text = TRStrings.tournament.localizedString
        guard let tournament = tournament else { return }
        titleDataLabel.text = tournament.title
        descDataLabel.text = tournament.description
        startTimeDataLabel.text = "\(tournament.startTime)"
        creatorDataLabel.text = tournament.creator.name
    }
}
