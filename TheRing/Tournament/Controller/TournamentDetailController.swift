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
            initController(tid: tid)
        } else {
            presentAlertPopRootVC(title: TRStrings.error.localizedString,
                                  message: TRStrings.errorCreator.localizedString)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        //Notification observer for didTapContestant
        let nameTapContNotif = Notification.Name(rawValue: NotificationStrings.didTapContestantNotificationName)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidTapContestant(_:)),
                                               name: nameTapContNotif, object: nil)
    }

    //Triggers on notification didTapImage
    @objc private func onDidTapContestant(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Int] {
            for (_, tag) in data {
                contestantTapped(tag: tag)
            }
        }
    }

    private func contestantTapped(tag: Int) {
        let pref = Preferences()
        if let tournament = tournament {
            let round = TournamentService.getCurrentRoundIndex(rounds: tournament.rounds)
            switch round {
            case 0:
                if tag < 4 {
                    tournamentView.colorBackground(index: tag)
                    TournamentService.registerVote(rid: tournament.rounds[round].rid, uid: pref.user.uid,
                                                   cid: tournament.contestants[tag].cid) { (error) in
                        if let error = error {
                            self.presentAlert(title: TRStrings.error.localizedString, message: error)
                        }
                    }
                }
            case 1:
                if tag > 3 {
                    tournamentView.colorBackground(index: tag)
                    TournamentService.registerVote(rid: tournament.rounds[round].rid, uid: pref.user.uid,
                                                   cid: tournament.contestants[tag].cid) { (error) in
                        if let error = error {
                            self.presentAlert(title: TRStrings.error.localizedString, message: error)
                        }
                    }
                }
            default:
                break
            }
        }
    }

    private func loadVotes() {
        let pref = Preferences()
        if let tournament = tournament {
            TournamentService.getVote(uid: pref.user.uid, rid: tournament.rounds[0].rid) { (cid) in
                if let cid = cid {
                    for (index, cont) in tournament.contestants.enumerated() where cid == cont.cid {
                        self.tournamentView.colorBackground(index: index)
                    }
                }
            }
            TournamentService.getVote(uid: pref.user.uid, rid: tournament.rounds[1].rid) { (cid) in
                if let cid = cid {
                    switch cid {
                    case tournament.contestants[0].cid, tournament.contestants[1].cid:
                        self.tournamentView.colorBackground(index: 4)
                    case tournament.contestants[2].cid, tournament.contestants[3].cid:
                        self.tournamentView.colorBackground(index: 5)
                    default:
                        break
                    }
                }
            }
        }
    }

    private func initController(tid: String) {
        TournamentService.getTournamentFull(tid: tid) { (tournament) in
            self.tournament = tournament
            if self.tournament != nil {
                self.setTexts()
                self.tournamentView.setView(tournament: tournament)
                self.loadVotes()
            } else {
                self.presentAlertPopRootVC(title: TRStrings.error.localizedString,
                                           message: TRStrings.errorCreator.localizedString)
            }
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
