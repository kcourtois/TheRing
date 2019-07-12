//
//  MovieCell.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import Kingfisher

class MovieCell: UITableViewCell {

    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!

    func configure(movie: Movie) {
        title.text = movie.title
        detail.text = movie.release_date
        let url = URL(string: movie.image)
        poster.kf.setImage(with: url)
    }
}
