//
//  MovieCell.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import Kingfisher

//shows movies poster and release date
class MovieCell: UITableViewCell {

    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!

    func configure(movie: Movie) {
        title.text = movie.title
        detail.text = "\(TRStrings.releaseDate.localizedString): \(localizedDetail(from: movie.release_date))"
        let url = URL(string: movie.image)
        poster.kf.setImage(with: url)
    }

    //func to localize release date
    private func localizedDetail(from string: String) -> String {
        if let date = Date(dateString: string) {
            let dateStr = date.dateToLocalizedString()
            let final = String(dateStr.split(separator: " ")[0])
            if final.last == "," {
                return String(final.prefix(final.count-1))
            } else {
                return final
            }
        } else {
            return string
        }
    }
}
