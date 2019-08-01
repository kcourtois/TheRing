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
    private var tournaments: [Tournament] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setTexts()
        hideKeyboardWhenTappedAround()
        tableView.tableFooterView = UIView()
        if let currUser = Auth.auth().currentUser {
            if preferences.user.uid != currUser.uid {
                loadUserPref(uid: currUser.uid)
            }
        } else {
            userNotLogged()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllTournaments()
    }

    @IBAction func goTapped(_ sender: Any) {
        if let text = searchBar.text {
            if !text.isEmpty {
                searchTournaments(search: text)
            } else {
                getAllTournaments()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "DetailTournamentSegue",
            let tournamentDetailVC = segue.destination as? TournamentDetailController,
            let tournamentIndex = tableView.indexPathForSelectedRow?.row else {
                return
        }
        tournamentDetailVC.tid = tournaments[tournamentIndex].tid
    }

    private func searchTournaments(search: String) {
        TournamentService.getAllTournaments(completion: { (tournaments) in
            var tmp = [Tournament]()
            for tournament in tournaments {
                if tournament.title.lowercased().contains(search.lowercased()) {
                    tmp.append(tournament)
                }
            }
            self.tournaments = tmp.sorted(by: { $0.startTime.compare($1.startTime) == .orderedDescending})
            self.tableView.reloadData()
        })
    }

    private func getAllTournaments() {
        TournamentService.getAllTournaments(completion: { (tournaments) in
            self.tournaments = tournaments.sorted(by: { $0.startTime.compare($1.startTime) == .orderedDescending})
            self.tableView.reloadData()
        })
    }

}

// MARK: - UI & Preferences setup
extension SearchController {
    //sets label texts
    private func setTexts() {
        self.title = TRStrings.search.localizedString
        searchBar.placeholder = TRStrings.search.localizedString
        if let items = tabBarController?.tabBar.items {
            items[0].title = TRStrings.home.localizedString
            items[1].title = TRStrings.user.localizedString
            items[2].title = TRStrings.create.localizedString
            items[3].title = TRStrings.search.localizedString
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
        UserService.getUserInfo(uid: uid) { (userData) in
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

extension SearchController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournaments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentCell", for: indexPath)
            as? TournamentCell else {
                return UITableViewCell()
        }

        let tournament = tournaments[indexPath.row]
        cell.configure(tournament: tournament)

        return cell
    }
}

extension SearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailTournamentSegue", sender: self)
    }
}
