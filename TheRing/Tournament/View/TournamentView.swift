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
    @IBOutlet var contestantImg:[UIImageView]!

    enum Stage1 {
        case grey, leftLeft, rightRight, leftRight, rightLeft
    }

    enum Stage2 {
        case grey, left, right
    }

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
    }

    //TODO: Replace with FULL Tournament, not created yet.
    func setView(tournament: TournamentData?) {
        if let tournament = tournament {
            let idx = TournamentService.getCurrentRoundIndex(rounds: tournament.rounds)
            let urls = [URL(string: tournament.rounds[idx].matches[0].contestant1.image),
                        URL(string: tournament.rounds[idx].matches[0].contestant2.image),
                        URL(string: tournament.rounds[idx].matches[1].contestant1.image),
                        URL(string: tournament.rounds[idx].matches[1].contestant2.image)]

            for index in 0..<4 {
                contestantImg[index].kf.setImage(with: urls[index])
            }

            roundLabel.text = "\(TRStrings.round.localizedString) \(idx+1)"
            endDateLabel.text = "\(TRStrings.endsOn.localizedString) \(tournament.rounds[idx].endDate)"
        }
    }

    private func setStages(first: Stage1, second: Stage2) {
        switch first {
        case .grey:
            stage1.image = #imageLiteral(resourceName: "n1-0")
            stage2.image = #imageLiteral(resourceName: "n2-0")
            stage3.image = #imageLiteral(resourceName: "n3-0")
            return
        case .leftLeft:
            stage1.image = #imageLiteral(resourceName: "n1-LL")
        case .rightRight:
            stage1.image = #imageLiteral(resourceName: "n1-RR")
        case .leftRight:
            stage1.image = #imageLiteral(resourceName: "n1-LR")
        case .rightLeft:
            stage1.image = #imageLiteral(resourceName: "n1-RL")
        }

        switch second {
        case .grey:
            stage2.image = #imageLiteral(resourceName: "n2-0")
            stage3.image = #imageLiteral(resourceName: "n3-0")
            return
        case .left:
            stage2.image = #imageLiteral(resourceName: "n2-L")
        case .right:
            stage2.image = #imageLiteral(resourceName: "n2-R")
        }

        stage3.image = #imageLiteral(resourceName: "n3-1")
    }

    //Get class name and turn it to a string
    private func selfName() -> String {
        let thisType = type(of: self)
        return String(describing: thisType)
    }
}
