//
//  TournamentDetailController.swift
//  TheRing
//
//  Created by Kévin Courtois on 18/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import Photos
//Controller that shows tournament detais, including the tournament view, the comments, and the vote system.
class TournamentDetailController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var descDataLabel: UILabel!
    @IBOutlet weak var startTimeDataLabel: UILabel!
    @IBOutlet weak var creatorDataButton: UIButton!
    @IBOutlet weak var tournamentView: TournamentView!

    private let tournamentDetailModel = TournamentDetailModel(tournamentService: FirebaseTournament(),
                                                              voteService: FirebaseVote())
    var tournament: TournamentData?

    override func viewDidLoad() {
        super.viewDidLoad()
        //check if user is logged in
        checkUserLogged()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //if tournament is set, we can set the view
        if let tournament = tournament {
            //set observers for notifications
            setObservers()
            //set texts for this screen
            setTexts()
            //set tournamentView xib
            tournamentView.setView(tournament: tournament,
                                   currentRound: tournamentDetailModel.getCurrentRoundIndex(
                                    rounds: tournament.rounds))
            //load votes of the user
            tournamentDetailModel.getUserVotes(uid: Preferences().user.uid, tournament: tournament)
            //load stages for contestant winners
            tournamentDetailModel.loadStages(tournament: tournament)
        } else {
            //else, show error and pop view
            presentAlertPopRootVC(title: TRStrings.error.localizedString,
                                  message: TRStrings.errorCreator.localizedString)
        }
    }

    //set observers for notifications
    private func setObservers() {
        //remove observers on view disappear
        NotificationCenter.default.addObserver(self, selector: #selector(onDidTapContestant),
                                               name: .didTapContestant, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidLoadVote),
                                               name: .didLoadVote, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendSetFirstView),
                                               name: .didSendSetFirstStage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendSetSecondView),
                                               name: .didSendSetSecondStage, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Notification observer for didTapContestant removed when view disappears
        NotificationCenter.default.removeObserver(self, name: .didTapContestant, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didLoadVote, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendSetFirstStage, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendSetSecondStage, object: nil)
    }

    //set texts for this screen
    private func setTexts() {
        startTimeLabel.text = TRStrings.startTime.localizedString
        creatorLabel.text = TRStrings.creator.localizedString
        self.title = TRStrings.tournament.localizedString
        guard let tournament = tournament else { return }
        descDataLabel.text = tournament.description
        startTimeDataLabel.text = tournament.startTime.dateToLocalizedString()
        creatorDataButton.setTitle(tournament.creator.name, for: .normal)
    }

    @IBAction func shareTapped(_ sender: Any) {
        //check permission if needed, and shares tournament if not
        checkPermission()
    }

    @IBAction func creatorTapped(_ sender: Any) {
        //segue to creator details
        performSegue(withIdentifier: "DetailUserSegue", sender: self)
    }

    //Triggers on notification didTapImage
    @objc private func onDidTapContestant(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Int] {
            for (_, tag) in data {
                if let tournament = tournament {
                    tournamentDetailModel.contestantTapped(uid: Preferences().user.uid, tag: tag,
                                                           tournament: tournament)
                } else {
                    presentAlert(title: TRStrings.error.localizedString,
                                 message: TRStrings.errorOccured.localizedString)
                }
            }
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

    //Triggers on notification didLoadVote
    @objc private func onDidLoadVote(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Int] {
            for (_, index) in data {
                self.tournamentView.colorBackground(index: index)
            }
        }
    }

    //Triggers on notification didSendSetFirstView
    @objc private func onDidSendSetFirstView(_ notification: Notification) {
        if let data = notification.userInfo as? [String: [String]] {
            for (_, cids) in data {
                tournamentView.setFirstStage(cids: cids)
            }
        }
    }

    //Triggers on notification didSendSetSecondView
    @objc private func onDidSendSetSecondView(_ notification: Notification) {
        if let data = notification.userInfo as? [String: [String]] {
            for (_, cids) in data {
                tournamentView.setSecondStage(cid: cids[0])
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "commentSegue":
            if let commentVC = segue.destination as? CommentController {
                commentVC.tid = tournament?.tid
            }
        case "DetailUserSegue":
            if let userDetailVC = segue.destination as? UserDetailController {
                userDetailVC.user = tournament?.creator
            }
        default:
            break
        }
    }
}
