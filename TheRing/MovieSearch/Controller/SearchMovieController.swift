//
//  SearchMovieController.swift
//  TheRing
//
//  Created by Kévin Courtois on 08/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class SearchMovieController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UITextField!

    var movies = [Movie]()
    weak var searchMovieDelegate: SearchMovieDelegate?

    override func viewDidLoad() {
        searchMovies()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    @IBAction func searchTapped(_ sender: Any) {
        guard let text = searchBar.text else {
            return
        }
        guard !text.isEmpty else {
            return
        }
        searchMovies(search: text)
    }

    func searchMovies(search: String = "") {
        MovieService.shared.getMovies(search: search) { (success, movieList) in
            if success, let movieList = movieList {
                self.movies = movieList
                self.tableView.reloadData()
            } else {
                self.presentAlert(title: TRStrings.error.localizedString,
                                  message: TRStrings.errorOccured.localizedString)
            }
        }
    }
}

extension SearchMovieController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
            as? MovieCell else {
                return UITableViewCell()
        }

        let movie = movies[indexPath.row]
        cell.configure(movie: movie)

        return cell
    }

}

extension SearchMovieController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        self.searchMovieDelegate?.passMovie(movie: movie)
        navigationController?.popViewController(animated: true)
    }
}

protocol SearchMovieDelegate: class {
    func passMovie(movie: Movie)
}
