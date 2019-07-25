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
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var contestantView: MovieOverview!
    @IBOutlet weak var pickButton: UIButton!
    var tournament: Tournament?
    private var movie: Movie?
    private var step: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        contestantView.setView(movie: movie)
        let customBackButton = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain,
                                               target: self, action: #selector(backAction(sender:)))
        customBackButton.imageInsets = UIEdgeInsets(top: 2, left: -8, bottom: 0, right: 0)
        navigationItem.leftBarButtonItem = customBackButton
        setTexts()
    }

    private func setTexts() {
        self.title = TRStrings.createTournaments.localizedString
        pickButton.setTitle(TRStrings.pick.localizedString, for: .normal)
        nextButton.setTitle(TRStrings.next.localizedString, for: .normal)
        sentenceLabel.text = "\(TRStrings.selectContestant.localizedString)1."
        contestantLabel.text = "\(TRStrings.contestant.localizedString) 1"
    }

    @objc func backAction(sender: UIBarButtonItem) {
        guard var tournament = tournament else {
            return
        }

        if step == tournament.contestants.count {
            tournament.contestants.removeLast()
            self.tournament = tournament
        }

        step -= 1

        if tournament.contestants.isEmpty {
            navigationController?.popViewController(animated: true)
            return
        }

        sentenceLabel.text = "\(TRStrings.selectContestant.localizedString)\(tournament.contestants.count)."
        contestantLabel.text = "\(TRStrings.contestant.localizedString) \(tournament.contestants.count)"
        contestantView.setView(movie: tournament.contestants.last)
        self.movie = tournament.contestants.last
        tournament.contestants.removeLast()
        self.tournament = tournament
    }

    private func nextContestantPick() {
        guard var tournament = tournament, let movie = movie else {
            return
        }

        if tournament.contestants.count < 4 {
            tournament.contestants.append(movie)
            self.tournament = tournament
        }

        if tournament.contestants.count > 3 {
            performSegue(withIdentifier: "datepickSegue", sender: self)
            return
        } else {
            step += 1
        }

        sentenceLabel.text = "\(TRStrings.selectContestant.localizedString)\(tournament.contestants.count+1)."
        contestantLabel.text = "\(TRStrings.contestant.localizedString) \(tournament.contestants.count+1)"
        contestantView.setView(movie: nil)
        self.movie = nil
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
