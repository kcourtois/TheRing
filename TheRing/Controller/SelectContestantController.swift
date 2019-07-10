//
//  SelectContestantController.swift
//  TheRing
//
//  Created by Kévin Courtois on 08/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class SelectContestantController: UIViewController, SearchMovieDelegate {
    @IBOutlet weak var sentenceLabel: UILabel!
    @IBOutlet weak var contestantLabel: UILabel!
    @IBOutlet weak var contestantView: MovieOverview!
    var tournament: Tournament?
    private var movie: Movie?

    override func viewDidLoad() {
        super.viewDidLoad()
        contestantView.setView(movie: movie)
    }

    private func nextContestantPick() {
        guard var tournament = tournament, let movie = movie else {
            return
        }
        if tournament.contestants.count+1 > 3 {
            performSegue(withIdentifier: "datepickSegue", sender: self)
            return
        }

        tournament.contestants.append(movie)

        sentenceLabel.text = "\(TRStrings.selectContestant.localizedString)\(tournament.contestants.count+1)."
        contestantLabel.text = "\(TRStrings.contestant.localizedString) \(tournament.contestants.count+1)"
        contestantView.setView(movie: nil)
        self.movie = nil
        self.tournament = tournament

    }

    @IBAction func pickTapped(_ sender: Any) {
        performSegue(withIdentifier: "contestantPickerSegue", sender: self)
    }

    @IBAction func nextTapped(_ sender: Any) {
        nextContestantPick()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "datepickSegue",
            let tournamentDateVC = segue.destination as? TournamentDateController {
            if let tournament = tournament {
                tournamentDateVC.tournament = tournament
            } else {
                return
            }
        } else if segue.identifier == "contestantPickerSegue",
            let contestantPickerVC = segue.destination as? SearchMovieController {
            contestantPickerVC.searchMovieDelegate = self
        }
    }

    func passMovie(movie: Movie) {
        self.movie = movie
        contestantView.setView(movie: movie)
    }
}
