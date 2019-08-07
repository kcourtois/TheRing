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
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var bottomComment: NSLayoutConstraint!

    var tid: String?
    private var comments: [Comment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //set texts for this screen
        setTexts()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
        //gives uiview instead of empty cells in the end of a tableview
        tableView.tableFooterView = UIView()
        //If tid is set, get comments
        if let tid = tid {
            TournamentService.getComments(tid: tid, completion: { (result) in
                self.comments = result
                self.tableView.reloadData()
            })
        }
        //set observers to know if keyboard shows or hides
        setKeyboardObservers()
    }

    //set observers to know if keyboard shows or hides
    private func setKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    //remove observers to know if keyboard shows or hides
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    //when keyboard shows, put bottomcomment on top of it
    @objc private func handleKeyboardWillShow(notification: Notification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let tabBarHeight = self.tabBarController!.tabBar.frame.size.height
        let height = (keyboardFrame?.height)! - tabBarHeight
        bottomComment.constant = height
        self.view.layoutIfNeeded()
    }

    //when keyboard shows, put bottomcomment back to its initial position
    @objc private func handleKeyboardWillHide(notification: Notification) {
        bottomComment.constant = 0
        self.view.layoutIfNeeded()
    }

    //when send is tapped, register comment and reload comments
    @IBAction func sendComment(_ sender: Any) {
        if let tid = tid, let comment = commentField.text {
            TournamentService.registerComment(tid: tid, comment: comment) { (error) in
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

    //set texts for this screen
    private func setTexts() {
        titleLabel.text = TRStrings.comments.localizedString
        sendButton.setTitle(TRStrings.send.localizedString, for: .normal)
        commentField.attributedPlaceholder = NSAttributedString(string: TRStrings.typeComment.localizedString,
                                                                attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0.6)])
    }
}

// MARK: - Comment Tableview datasource
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentField.resignFirstResponder()
        return true
    }
}
