//
//  TournamentDetailController.swift
//  TheRing
//
//  Created by Kévin Courtois on 18/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import Photos

class TournamentDetailController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var descDataLabel: UILabel!
    @IBOutlet weak var startTimeDataLabel: UILabel!
    @IBOutlet weak var creatorDataLabel: UILabel!
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

    @IBAction func shareTapped(_ sender: Any) {
        if checkPermission() {
            shareTournament()
        }
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
        if let tournament = tournament {
            let round = TournamentService.getCurrentRoundIndex(rounds: tournament.rounds)
            switch round {
            case 0:
                if tag < 4 {
                    tournamentView.colorBackground(index: tag)
                    vote(round: round, cid: tournament.contestants[tag].cid)
                }
            case 1:
                if tag > 3 && tag < 6 {
                    tournamentView.colorBackground(index: tag)
                    getWinner(round: round-1) { (res) in
                        if let cid = res {
                            self.vote(round: round, cid: cid[tag-4])
                        }
                    }
                }
            default:
                break
            }
        }
    }

    private func vote(round: Int, cid: String) {
        guard let tournament = tournament else {
            return
        }
        let pref = Preferences()
        TournamentService.getUserVote(uid: pref.user.uid, rid: tournament.rounds[round].rid) { (result) in
            if let contId = result {
                TournamentService.removeUserVote(uid: pref.user.uid,
                                                 rid: tournament.rounds[round].rid, cid: contId)
            }

            TournamentService.registerVote(rid: tournament.rounds[round].rid,
                                           uid: pref.user.uid,
                                           cid: cid) { (error) in
                if let error = error {
                    self.presentAlert(title: TRStrings.error.localizedString, message: error)
                }
            }
        }
    }

    private func getWinner(round: Int, completion: @escaping ([String]?) -> Void) {
        guard let tournament = tournament else {
            completion(nil)
            return
        }
        var contRes = [UInt]()
        let max = tournament.contestants.count/(round+1)
        let dispatchGroup = DispatchGroup()

        for _ in 0..<max {
            contRes.append(0)
        }

        for ind in 0..<max {
            dispatchGroup.enter()
            TournamentService.getVotes(cid: tournament.contestants[ind].cid,
                                       rid: tournament.rounds[round].rid) { (res) in
                if let res = res {
                    contRes[ind] = res
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            var result = [String]()
            for index in stride(from: 0, to: max-1, by: 2) {
                if contRes[index] >= contRes[index+1] {
                    result.append(tournament.contestants[index].cid)
                } else {
                    result.append(tournament.contestants[index+1].cid)
                }
            }
            completion(result)
        }
    }

    private func initController(tid: String) {
        TournamentService.getTournamentFull(tid: tid) { (tournament) in
            self.tournament = tournament
            if self.tournament != nil {
                self.setTexts()
                self.tournamentView.setView(tournament: tournament)
                self.loadVotes()
                self.loadStages()
            } else {
                self.presentAlertPopRootVC(title: TRStrings.error.localizedString,
                                           message: TRStrings.errorCreator.localizedString)
            }
        }
    }

    private func loadVotes() {
        let pref = Preferences()
        if let tournament = tournament {
            TournamentService.getUserVote(uid: pref.user.uid, rid: tournament.rounds[0].rid) { (cid) in
                if let cid = cid {
                    for (index, cont) in tournament.contestants.enumerated() where cid == cont.cid {
                        self.tournamentView.colorBackground(index: index)
                    }
                }
            }
            TournamentService.getUserVote(uid: pref.user.uid, rid: tournament.rounds[1].rid) { (cid) in
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

    private func loadStages() {
        guard let tournament = tournament else {
            return
        }
        let round = TournamentService.getCurrentRoundIndex(rounds: tournament.rounds)
        if round > 0 {
            getWinner(round: round-1) { (cids) in
                if let cids = cids {
                    self.tournamentView.setFirstStage(cids: cids)
                }
            }
            if tournament.rounds[round].endDate < Date() {
                getWinner(round: round) { (cids) in
                    if let cids = cids {
                        self.tournamentView.setSecondStage(cid: cids[0])
                    }
                }
            }
        }
    }

    private func setTexts() {
        startTimeLabel.text = TRStrings.startTime.localizedString
        creatorLabel.text = TRStrings.creator.localizedString
        self.title = TRStrings.tournament.localizedString
        guard let tournament = tournament else { return }
        descDataLabel.text = tournament.description
        startTimeDataLabel.text = "\(tournament.startTime)"
        creatorDataLabel.text = tournament.creator.name
    }

    //Present view to user for image share
    private func shareTournament() {
        let items = [getTournamentAsImage()]
        let act = UIActivityViewController(activityItems: items, applicationActivities: nil)
        act.completionWithItemsHandler = { activity, completed, items, error in
            if !completed {
                self.presentAlert(title: TRStrings.shareFailed.localizedString,
                                  message: TRStrings.failedToShare.localizedString)
            } else {
                self.presentAlert(title: TRStrings.shareSucceeded.localizedString,
                                  message: TRStrings.successShare.localizedString)
            }
        }

        present(act, animated: true, completion: nil)
    }

    //Convert tournamentView to an image
    private func getTournamentAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: tournamentView.bounds.size)
        let image = renderer.image { _ in
            tournamentView.drawHierarchy(in: tournamentView.bounds, afterScreenUpdates: true)
        }
        return image
    }

    //Check photo library permission
    private func checkPermission() -> Bool {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            return true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { _ in }
            return checkPermission()
        case .restricted:
            presentPermissionDeniedAlert()
            return false
        case .denied:
            presentPermissionDeniedAlert()
            return false
        @unknown default:
            return false
        }
    }

    //Shows a popup to access settings if user denied photolibrary permission
    private func presentPermissionDeniedAlert() {
        //Initialisation of the alert
        let alertController = UIAlertController(title: "Permission denied",
                                                message: "Please go to Settings and turn on the permissions for Photo access.",
                                                preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (_) in })
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        //Shows alert
        present(alertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "commentSegue",
            let commentVC = segue.destination as? CommentController else {
                return
        }
        commentVC.tid = tid
    }
}
