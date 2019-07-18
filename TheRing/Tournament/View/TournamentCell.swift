//
//  TournamentCell.swift
//  TheRing
//
//  Created by Kévin Courtois on 16/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class TournamentCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func configure(tournament: Tournament) {
        titleLabel.text = tournament.title
        descriptionLabel.text = tournament.description
    }
}
