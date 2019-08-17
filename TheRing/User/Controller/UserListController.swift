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

    private let userListModel = UserListModel(userService: FirebaseUser())
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
            case .subscriptions:
                self.title = TRStrings.mySubscriptions.localizedString
            }
            userListModel.getSubs(userType: userType)
        } else {
            presentAlert(title: TRStrings.error.localizedString,
                         message: TRStrings.errorOccured.localizedString)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //set observers on view appear
        super.viewWillAppear(animated)
        //set observers for notifications
        setObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //remove observers on view disappear
        NotificationCenter.default.removeObserver(self, name: .didSendSubs, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendUserInfo, object: nil)
    }

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didSendSubs
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendSubs),
                                               name: .didSendSubs, object: nil)
        //Notification observer for didSendError
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
        //Notification observer for didSendUserInfo
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendUserInfo),
                                               name: .didSendUserInfo, object: nil)
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

    //Triggers on notification didSendError
    @objc private func onDidSendError(_ notification: Notification) {
        if let data = notification.userInfo as? [String: String] {
            for (_, error) in data {
                presentAlert(title: TRStrings.error.localizedString, message: error)
            }
        }
    }

    //Triggers on notification didSendSubs
    @objc private func onDidSendSubs(_ notification: Notification) {
        if let data = notification.userInfo as? [String: [TRUser]] {
            for (_, users) in data {
                self.users = users
                self.tableView.reloadData()
            }
        }
    }

    //Triggers on notification didSendUserInfo
    @objc private func onDidSendUserInfo(_ notification: Notification) {
        if let data = notification.userInfo as? [String: TRUser] {
            for (_, user) in data {
                userTapped = user
                performSegue(withIdentifier: "DetailUserSegue", sender: self)
            }
        }
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
        userListModel.getUserInfo(uid: users[indexPath.row].uid)
    }
}
