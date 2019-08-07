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
    @IBOutlet weak var creatorDataButton: UIButton!
    @IBOutlet weak var tournamentView: TournamentView!

    var tournament: TournamentData?

    override func viewDidLoad() {
        super.viewDidLoad()
        //if tournament is set, we can set the view
        if let tournament = tournament {
            //set texts for this screen
            setTexts()
            //set tournamentView xib
            tournamentView.setView(tournament: tournament)
            //load votes of the user
            loadVotes()
            //load stages for contestant winners
            loadStages()
        } else {
            //else, show error and pop view
            presentAlertPopRootVC(title: TRStrings.error.localizedString,
                                  message: TRStrings.errorCreator.localizedString)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Notification observer for didTapContestant added when view appears
        let nameTapContNotif = Notification.Name(rawValue: NotificationStrings.didTapContestantNotificationName)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidTapContestant(_:)),
                                               name: nameTapContNotif, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Notification observer for didTapContestant removed when view disappears
        let nameTapContNotif = Notification.Name(rawValue: NotificationStrings.didTapContestantNotificationName)
        NotificationCenter.default.removeObserver(self, name: nameTapContNotif, object: nil)
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
                contestantTapped(tag: tag)
            }
        }
    }

    //vote for the tapped contestant if possible
    private func contestantTapped(tag: Int) {
        if let tournament = tournament {
            let round = TournamentService.getCurrentRoundIndex(rounds: tournament.rounds)
            switch round {
            //if first round and image tapped < 4, vote
            case 0:
                if tag < 4 {
                    tournamentView.colorBackground(index: tag)
                    vote(round: round, cid: tournament.contestants[tag].cid)
                }
            //if second round and image tapped > 3 and < 6, vote
            case 1:
                if tag > 3 && tag < 6 && tournament.rounds[round].endDate > Date() {
                    tournamentView.colorBackground(index: tag)
                    getWinner(round: 0, cids: tournament.getCids()) { (res) in
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

    //vote in database through tournament service
    private func vote(round: Int, cid: String) {
        guard let tournament = tournament else {
            return
        }
        let pref = Preferences()
        //check if user already had a registered vote
        TournamentService.getUserVote(uid: pref.user.uid, rid: tournament.rounds[round].rid) { (result) in
            if let contId = result {
                //if he had, remove it
                TournamentService.removeUserVote(uid: pref.user.uid,
                                                 rid: tournament.rounds[round].rid, cid: contId)
            }

            //vote for the new contestant
            TournamentService.registerVote(rid: tournament.rounds[round].rid,
                                           uid: pref.user.uid,
                                           cid: cid) { (error) in
                if let error = error {
                    self.presentAlert(title: TRStrings.error.localizedString, message: error)
                }
            }
        }
    }

    //Returns the winner of a given round
    private func getWinner(round: Int, cids: [String], completion: @escaping ([String]?) -> Void) {
        guard let tournament = tournament else {
            completion(nil)
            return
        }
        var contRes = [UInt]()
        let dispatchGroup = DispatchGroup()

        //Append blank votes results for each contestant
        for _ in 0..<cids.count {
            contRes.append(0)
        }

        //get votes count for all contestants
        for ind in 0..<cids.count {
            dispatchGroup.enter()
            TournamentService.getVotes(cid: cids[ind],
                                       rid: tournament.rounds[round].rid) { (res) in
                if let res = res {
                    contRes[ind] = res
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            var result = [String]()
            //check winner of each duel
            for index in stride(from: 0, to: cids.count-1, by: 2) {
                if contRes[index] >= contRes[index+1] {
                    result.append(cids[index])
                } else {
                    result.append(cids[index+1])
                }
            }
            completion(result)
        }
    }

    //loads user votes
    private func loadVotes() {
        let pref = Preferences()
        if let tournament = tournament {
            //get vote for round 1
            TournamentService.getUserVote(uid: pref.user.uid, rid: tournament.rounds[0].rid) { (cid) in
                if let cid = cid {
                    for (index, cont) in tournament.contestants.enumerated() where cid == cont.cid {
                        self.tournamentView.colorBackground(index: index)
                    }
                }
            }
            //get vote for round 2
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

    //load UI for stages of the tournament, showing winner of rounds etc.
    private func loadStages() {
        guard let tournament = tournament else {
            return
        }
        let round = TournamentService.getCurrentRoundIndex(rounds: tournament.rounds)
        if round > 0 {
            getWinner(round: round-1, cids: tournament.getCids()) { (result) in
                if let cids = result {
                    self.tournamentView.setFirstStage(cids: cids)
                    if tournament.rounds[round].endDate < Date() {
                        self.getWinner(round: round, cids: cids) { (result) in
                            if let res = result {
                                self.tournamentView.setSecondStage(cid: res[0])
                            }
                        }
                    }
                } else {
                    return
                }
            }
        }
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

    //Present view to user for image share
    private func shareWithUrlAndText() {
        guard let url = URL(string: "https://github.com/kcourtois/TheRing") else {
            presentAlert(title: TRStrings.error.localizedString, message: TRStrings.errorOccured.localizedString)
            return
        }
        let text = TRStrings.shareTournament.localizedString
        let image = getTournamentAsImage()

        let shareAll = [text, image, url] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    //Convert tournamentView to an image
    private func getTournamentAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: tournamentView.bounds.size)
        let image = renderer.image { _ in
            tournamentView.drawHierarchy(in: tournamentView.bounds, afterScreenUpdates: true)
        }
        return image
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

// MARK: - Photo permission

extension TournamentDetailController {
    //Check photo library permission
    private func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            shareWithUrlAndText()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { result in
                if result == .authorized {
                    self.presentAlert(title: TRStrings.permissionGranted.localizedString,
                                      message: TRStrings.shareAuthorized.localizedString)
                } else {
                    self.presentPermissionDeniedAlert()
                }
            }
        case .restricted:
            presentPermissionDeniedAlert()
        case .denied:
            presentPermissionDeniedAlert()
        @unknown default:
            presentPermissionDeniedAlert()
        }
    }

    //Shows a popup to access settings if user denied photolibrary permission
    private func presentPermissionDeniedAlert() {
        //Initialisation of the alert
        let alertController = UIAlertController(title: TRStrings.permissionDenied.localizedString,
                                                message: TRStrings.goToSettings.localizedString,
                                                preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: TRStrings.settings.localizedString, style: .default) { (_) -> Void in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (_) in })
                }
            }
        }
        let cancelAction = UIAlertAction(title: TRStrings.cancel.localizedString, style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        //Shows alert
        present(alertController, animated: true, completion: nil)
    }
}
