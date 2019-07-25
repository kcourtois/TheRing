//
//  TournamentView.swift
//  TheRing
//
//  Created by Kévin Courtois on 18/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import Kingfisher

class TournamentView: UIView {

    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var stage3: UIImageView!
    @IBOutlet weak var stage2: UIImageView!
    @IBOutlet weak var stage1: UIImageView!
    @IBOutlet var contestantImg: [UIImageView]!

    var tournament: TournamentData?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    //Initalisation of the xib
    func commonInit() {
        //Load xib by name
        let contentView = Bundle.main.loadNibNamed(selfName(), owner: self, options: nil)?.first as? UIView ?? UIView()
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)
        initTapGesures()
    }

    func setView(tournament: TournamentData?) {
        if let tournament = tournament {
            self.tournament = tournament
            let idx = TournamentService.getCurrentRoundIndex(rounds: tournament.rounds)

            for index in 0..<4 {
                contestantImg[index].kf.setImage(with: URL(string: tournament.contestants[index].image))
            }

            roundLabel.text = "\(TRStrings.round.localizedString) \(idx+1)"
            endDateLabel.text = "\(TRStrings.endsOn.localizedString) \(tournament.rounds[idx].endDate)"
        }
    }

    func setFirstStage(cids: [String]) {
        guard let tournament = tournament, cids.count == 2 else {
            return
        }
        if cids[0] == tournament.contestants[0].cid && cids[1] == tournament.contestants[2].cid {
            stage1.image = #imageLiteral(resourceName: "n1-LL")
            contestantImg[4].image = contestantImg[0].image
            contestantImg[5].image = contestantImg[2].image
        } else if cids[0] == tournament.contestants[0].cid && cids[1] == tournament.contestants[3].cid {
            stage1.image = #imageLiteral(resourceName: "n1-LR")
            contestantImg[4].image = contestantImg[0].image
            contestantImg[5].image = contestantImg[3].image
        } else if cids[0] == tournament.contestants[1].cid && cids[1] == tournament.contestants[3].cid {
            stage1.image = #imageLiteral(resourceName: "n1-RR")
            contestantImg[4].image = contestantImg[1].image
            contestantImg[5].image = contestantImg[3].image
        } else if cids[0] == tournament.contestants[1].cid && cids[1] == tournament.contestants[2].cid {
            stage1.image = #imageLiteral(resourceName: "n1-RL")
            contestantImg[4].image = contestantImg[1].image
            contestantImg[5].image = contestantImg[2].image
        }
    }

    func setSecondStage(cid: String) {
        guard let tournament = tournament else {
            return
        }

        for (index, contestant) in tournament.contestants.enumerated() where cid == contestant.cid {
            contestantImg[6].image = contestantImg[index].image
            stage2.image = index < tournament.contestants.count/2 ? #imageLiteral(resourceName: "n2-L") : #imageLiteral(resourceName: "n2-R")
            stage3.image = #imageLiteral(resourceName: "n3-1")
        }
    }

    //Adds tap gestures to imageViews in array
    func initTapGesures() {
        for imageView in contestantImg {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                              action: #selector(contestantTapped(sender:)))
            imageView.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    //func triggered when an imageview is tapped. Sends a notification to the viewcontroller
    @objc private func contestantTapped(sender: UITapGestureRecognizer) {
        if let view = sender.view {
            let name = Notification.Name(rawValue: NotificationStrings.didTapContestantNotificationName)
            NotificationCenter.default.post(name: name, object: nil,
                                            userInfo: [NotificationStrings.didTapContestantParameterKey: view.tag])
        }
    }

    func colorBackground(index: Int) {
        switch index {
        case 0, 1, 2, 3:
            for ind in 0..<4 {
                contestantImg[ind].backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 0)
            }
            contestantImg[index].backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        case 4:
            contestantImg[4].backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            contestantImg[5].backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 0)
        case 5:
            contestantImg[5].backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            contestantImg[4].backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 0)
        default:
            break
        }
    }

    //Get class name and turn it to a string
    private func selfName() -> String {
        let thisType = type(of: self)
        return String(describing: thisType)
    }
}
