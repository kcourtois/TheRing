//
//  TournamentOverview.swift
//  TheRing
//
//  Created by Kévin Courtois on 02/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
//View that is used in overviewcell, with the title of the tournament and the four movies
class TournamentOverview: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var contestantImg: [UIImageView]!

    var tournament: TournamentData?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    //Initalisation of the xib
    private func commonInit() {
        //Load xib by name
        let contentView = Bundle.main.loadNibNamed(selfName(), owner: self, options: nil)?.first as? UIView ?? UIView()
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)
    }

    //Called by owner view, gives a tournament to set title and images
    func setView(tournament: TournamentData) {
        self.tournament = tournament
        for index in 0..<4 {
            contestantImg[index].kf.setImage(with: URL(string: tournament.contestants[index].image))
        }
        titleLabel.text = tournament.title
    }

    //Get class name and turn it to a string
    private func selfName() -> String {
        let thisType = type(of: self)
        return String(describing: thisType)
    }
}
