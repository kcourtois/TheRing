//
//  HomeController.swift
//  TheRing
//
//  Created by Kévin Courtois on 26/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class HomeController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var tournaments = [TournamentData]()
    private let homeModel = HomeModel(authService: FirebaseAuth(), userService: FirebaseUser(),
                                      tournamentService: FirebaseTournament())

    override func viewDidLoad() {
        super.viewDidLoad()
        //set texts for this screen
        setTexts()
        //gives uiview instead of empty cells in the end of a tableview
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkUserLogged()
        //Load user tournaments
        homeModel.getUserTournaments()
        //set observers for notifications
        setObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //remove observers on view disappear
        NotificationCenter.default.removeObserver(self, name: .didSendTournamentData, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
    }

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didSendTournamentData
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendTournamentData),
                                               name: .didSendTournamentData, object: nil)
        //Notification observer for didSendError
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
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

    //Triggers on notification didSendError
    @objc private func onDidSendError(_ notification: Notification) {
        if let data = notification.userInfo as? [String: String] {
            for (_, error) in data {
                //dismissLoadAlertWithMessage(alert: alert, title: TRStrings.error.localizedString,
                //                            message: error)
                presentAlert(title: TRStrings.error.localizedString,
                             message: error)
            }
        }
    }

    //Triggers on notification didSendTournamentData
    @objc private func onDidSendTournamentData(_ notification: Notification) {
        if let data = notification.userInfo as? [String: [TournamentData]] {
            for (_, tournaments) in data {
                self.tournaments = tournaments
                tableView.reloadData()
            }
        }
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
