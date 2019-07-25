//
//  CommentController.swift
//  TheRing
//
//  Created by Kévin Courtois on 25/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class CommentController: UIViewController {

    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var tid: String?
    private var comments: [Comment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setTexts()
        tableView.tableFooterView = UIView()
        if let tid = tid {
            TournamentService.getComments(tid: tid, completion: { (result) in
                self.comments = result
                self.tableView.reloadData()
            })
        }
    }

    @IBAction func sendComment(_ sender: Any) {
        let pref = Preferences()
        if let tid = tid, let comment = commentField.text {
            TournamentService.registerComment(tid: tid, user: pref.user, comment: comment) { (error) in
                if let error = error {
                    self.presentAlert(title: TRStrings.error.localizedString, message: error)
                }
                self.commentField.text = ""
                TournamentService.getComments(tid: tid, completion: { (result) in
                    self.comments = result
                    self.tableView.reloadData()
                })
            }
        }
    }

    private func setTexts() {
        titleLabel.text = TRStrings.comments.localizedString
        sendButton.setTitle(TRStrings.send.localizedString, for: .normal)
    }
}

extension CommentController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)

        let comment = comments[indexPath.row]

        cell.textLabel?.text = comment.username
        cell.detailTextLabel?.text = comment.comment

        return cell
    }
}

// MARK: - Keyboard
extension CommentController: UITextFieldDelegate {
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        commentField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentField.resignFirstResponder()
        return true
    }
}
