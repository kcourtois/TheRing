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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        if let userType = userType {
            switch userType {
            case .subscribers:
                self.title = TRStrings.mySubscribers.localizedString
                UserService.getUserSubscribers(completion: { (users) in
                    self.users = users
                    self.tableView.reloadData()
                })
            case .subscriptions:
                self.title = TRStrings.mySubscriptions.localizedString
                UserService.getUserSubscriptions(completion: { (users) in
                    self.users = users
                    self.tableView.reloadData()
                })
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "DetailUserSegue",
            let userDetailVC = segue.destination as? UserDetailController,
            let userIndex = tableView.indexPathForSelectedRow?.row else {
                return
        }
        userDetailVC.uid = users[userIndex].uid
    }
}

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

extension UserListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailUserSegue", sender: self)
    }
}
