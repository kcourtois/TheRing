//
//  SearchController.swift
//  TheRing
//
//  Created by Kévin Courtois on 01/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import FirebaseAuth

class SearchController: UIViewController {
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var tableView: UITableView!

    private let preferences = Preferences()
    private var tournaments: [TournamentData] = []
    private let userService: UserService = FirebaseUser()
    private let tournamentService: TournamentService = FirebaseTournament()

    override func viewDidLoad() {
        super.viewDidLoad()
        //set texts for this screen
        setTexts()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
        //gives uiview instead of empty cells in the end of a tableview
        tableView.tableFooterView = UIView()
        //Check if user logged
        if let currUser = Auth.auth().currentUser {
            //Check if user pref are up to date
            if preferences.user.uid != currUser.uid {
                loadUserPref(uid: currUser.uid)
            }
        } else {
            userNotLogged()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //refresh tournaments on view appear
        getAllTournaments()
    }

    //Search tournaments when go tapped
    @IBAction func goTapped(_ sender: Any) {
        if let text = searchBar.text {
            if !text.isEmpty {
                searchTournaments(search: text)
            } else {
                getAllTournaments()
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

    //gets all tournaments and select only those who contains the search string in title
    private func searchTournaments(search: String) {
        tournamentService.getAllTournaments(completion: { (tournaments) in
            var tmp = [TournamentData]()
            for tournament in tournaments {
                if tournament.title.lowercased().contains(search.lowercased()) {
                    tmp.append(tournament)
                }
            }
            //sorts tournament form newest to oldest
            self.tournaments = tmp.sorted(by: { $0.startTime.compare($1.startTime) == .orderedDescending})
            self.tableView.reloadData()
        })
    }

    //gets all tournaments, sort them from newest to oldest and reloads tableview
    private func getAllTournaments() {
        tournamentService.getAllTournaments(completion: { (tournaments) in
            self.tournaments = tournaments.sorted(by: { $0.startTime.compare($1.startTime) == .orderedDescending})
            self.tableView.reloadData()
        })
    }
}

// MARK: - UI & Preferences setup
extension SearchController {
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

    //sends user back to login screen
    private func userNotLogged() {
        presentAlertDelay(title: TRStrings.error.localizedString,
                          message: TRStrings.notLogged.localizedString,
                          delay: 2.0, completion: {
                            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        })
    }

    //loads user in preferences
    private func loadUserPref(uid: String) {
        let alert = loadingAlert()
        userService.getUserInfo(uid: uid) { (userData) in
            if let user = userData {
                self.preferences.user = user
                alert.dismiss(animated: true, completion: nil)
            } else {
                alert.dismiss(animated: true, completion: {
                    self.presentAlert(title: TRStrings.error.localizedString,
                                      message: TRStrings.userNotRetrieved.localizedString)
                })
            }
        }
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
