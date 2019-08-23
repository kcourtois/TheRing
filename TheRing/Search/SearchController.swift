//
//  SearchController.swift
//  TheRing
//
//  Created by Kévin Courtois on 01/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

//Controller used to search through all the tournaments that were created
class SearchController: UIViewController {
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var tableView: UITableView!

    private var tournaments: [TournamentData] = []
    private let searchModel = SearchModel(tournamentService: FirebaseTournament())
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        //set texts for this screen
        setTexts()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
        //gives uiview instead of empty cells in the end of a tableview
        tableView.tableFooterView = UIView()
        //refresh tournaments on view appear
        searchModel.getAllTournaments()
        //setup refresh control
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(onDidAskRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //check if user is logged in
        checkUserLogged()
        //set observers for notifications
        setObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //remove observers on view disappear
        NotificationCenter.default.removeObserver(self, name: .didSendTournamentData, object: nil)
    }

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didSendTournamentData
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendTournamentData),
                                               name: .didSendTournamentData, object: nil)
    }

    //set texts for this screen
    private func setTexts() {
        self.title = TRStrings.tournaments.localizedString
        searchBar.placeholder = TRStrings.search.localizedString
        if let items = tabBarController?.tabBar.items {
            items[0].title = TRStrings.home.localizedString
            items[1].title = TRStrings.user.localizedString
            items[2].title = TRStrings.tournaments.localizedString
        }
    }

    //Search tournaments when go tapped
    @IBAction func goTapped(_ sender: Any) {
        if let text = searchBar.text {
            if !text.isEmptyAfterTrim {
                searchModel.getAllTournaments(search: text)
            } else {
                searchModel.getAllTournaments()
            }
        }
    }

    //to create a new tournament, we need to segue to CreateTournamentController
    @IBAction func createTapped(_ sender: Any) {
        performSegue(withIdentifier: "createTournamentSegue", sender: self)
    }

    //prepare detail view with tournament data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailTournamentSegue",
            let tournamentDetailVC = segue.destination as? TournamentDetailController,
            let tournamentIndex = tableView.indexPathForSelectedRow?.row {
                tournamentDetailVC.tournament = tournaments[tournamentIndex]
        }
    }

    //Triggers on notification didSendTournamentData
    @objc private func onDidSendTournamentData(_ notification: Notification) {
        if let data = notification.userInfo as? [String: [TournamentData]] {
            for (_, tournaments) in data {
                self.tournaments = tournaments
                tableView.reloadData()
                refreshControl.endRefreshing()
            }
        }
    }

    //Triggers on notification didSendTournamentData
    @objc private func onDidAskRefresh() {
        searchModel.getAllTournaments()
    }
}

// MARK: - Keyboard dismiss and placeholders setup
extension SearchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

// MARK: - Tableview datasource
extension SearchController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournaments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OverviewCell", for: indexPath)
            as? OverviewCell else {
                return UITableViewCell()
        }

        let tournament = tournaments[indexPath.row]
        cell.configure(tournament: tournament)

        return cell
    }
}

// MARK: - Tableview delegare
extension SearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailTournamentSegue", sender: self)
    }
}
