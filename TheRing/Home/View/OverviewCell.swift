//
//  OverviewCell.swift
//  TheRing
//
//  Created by Kévin Courtois on 05/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class OverviewCell: UITableViewCell {
    @IBOutlet weak var overview: TournamentOverview!

    func configure(tournament: TournamentData) {
        overview.setView(tournament: tournament)
    }
}
