//
//  UserListController.swift
//  TheRing
//
//  Created by Kévin Courtois on 26/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class UserListController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var users: [TRUser] = []
    var userType: UserListType?
    var userTapped: TRUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        //gives uiview instead of empty cells in the end of a tableview
        tableView.tableFooterView = UIView()
        //if usertype is set
        if let userType = userType {
            switch userType {
            case .subscribers:
                self.title = TRStrings.mySubscribers.localizedString
                //Get list of subscribers for current user
                UserService.getUserSubscribers(completion: { (users) in
                    self.users = users
                    self.tableView.reloadData()
                })
            case .subscriptions:
                self.title = TRStrings.mySubscriptions.localizedString
                //Get list of subscriptions for current user
                UserService.getUserSubscriptions(completion: { (users) in
                    self.users = users
                    self.tableView.reloadData()
                })
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Set user before showing detail view
        guard segue.identifier == "DetailUserSegue",
            let userDetailVC = segue.destination as? UserDetailController,
            let theUser = userTapped else {
                return
        }
        userDetailVC.user = theUser
    }
}

// MARK: - Tableview datasource
extension UserListController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
            as? UserCell else {
                return UITableViewCell()
        }

        let user = users[indexPath.row]
        cell.configure(user: user)

        return cell
    }
}

// MARK: - Tableview delegare
extension UserListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //on clic, get user info and show detail view
        UserService.getUserInfo(uid: users[indexPath.row].uid) { (user) in
            self.userTapped = user
            self.performSegue(withIdentifier: "DetailUserSegue", sender: self)
        }
    }
}
