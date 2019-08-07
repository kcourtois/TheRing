//
//  MovieOverview.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import Kingfisher

class MovieOverview: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var overview: UITextView!
    @IBOutlet weak var titleOverview: UILabel!

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

    //set view with given movie (load image, title, overview, genre...)
    func setView(movie: Movie?) {
        if let movie = movie {
            let url = URL(string: movie.image)
            imageView.kf.setImage(with: url)
            title.text = movie.title
            releaseDate.text = "\(TRStrings.releaseDate.localizedString): \(movie.release_date)"
            note.text = "\(TRStrings.rating.localizedString): \(movie.vote_average)"
            overview.text = movie.overview
            setGenre(ids: movie.genre_ids)
            titleOverview.text = "\(TRStrings.overview.localizedString)"
        } else {
            imageView.image = nil
            title.text = nil
            releaseDate.text = nil
            note.text = nil
            titleOverview.text = nil
            overview.text = nil
            setGenre(ids: [])
        }
    }

    //set movie genre, with a list of categories defined by the api.
    private func setGenre(ids: [Int]) {
        if ids.isEmpty {
            genres.text = nil
        } else {
            var txt = "\(TRStrings.category.localizedString):"
            for ident in ids {
                if let genre = Genre(rawValue: ident) {
                    txt += " \(genre.localizedString),"
                }
            }
            genres.text = String(txt.dropLast())
        }
    }

    //Get class name and turn it to a string
    private func selfName() -> String {
        let thisType = type(of: self)
        return String(describing: thisType)
    }
}
