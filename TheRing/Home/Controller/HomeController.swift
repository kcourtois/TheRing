//
//  HomeController.swift
//  TheRing
//
//  Created by Kévin Courtois on 26/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let preferences = Preferences()

    private var tournaments = [TournamentData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //set texts for this screen
        setTexts()
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
        //Load user tournaments
        TournamentService.getUserTournamentsWithData(completion: { (tournaments) in
            //sort tournaments from most recent to oldest
            self.tournaments = tournaments.sorted(by: { $0.startTime.compare($1.startTime) == .orderedDescending})
            self.tableView.reloadData()
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Set tournament data before showing detail view
        guard segue.identifier == "DetailTournamentSegue",
            let tournamentDetailVC = segue.destination as? TournamentDetailController,
            let tournamentIndex = tableView.indexPathForSelectedRow?.row else {
                return
        }
        tournamentDetailVC.tournament = tournaments[tournamentIndex]
    }
}

// MARK: - UI & Preferences setup
extension HomeController {
    //set texts for this screen
    private func setTexts() {
        self.title = TRStrings.home.localizedString
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

// MARK: - Tableview datasource
extension HomeController: UITableViewDataSource {
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
extension HomeController: UITableViewDelegate {
    //On clic, perform segue to detail view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailTournamentSegue", sender: self)
    }
}
