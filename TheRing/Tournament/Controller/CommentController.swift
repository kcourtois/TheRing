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
    private let commentModel = CommentModel(commentService: FirebaseComment())

    override func viewDidLoad() {
        super.viewDidLoad()
        //set texts for this screen
        setTexts()
        //keyboard disappear after tap
        hideKeyboardWhenTappedAround()
        //gives uiview instead of empty cells in the end of a tableview
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set observers for notifications
        setObservers()
        //If tid is set, get comments
        if let tid = tid {
            commentModel.getComments(tid: tid)
        } else {
            presentAlert(title: TRStrings.error.localizedString, message: TRStrings.errorOccured.localizedString)
        }
    }

    //set observers for notifications
    private func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidRegisterComment),
                                               name: .didRegisterComment, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendComments),
                                               name: .didSendComments, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //remove observers on view disappear
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didRegisterComment, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendComments, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    //when send is tapped, register comment and reload comments
    @IBAction func sendComment(_ sender: Any) {
        if let tid = tid, let comment = commentField.text {
            commentModel.registerComment(tid: tid, comment: comment)
        } else {
            presentAlert(title: TRStrings.error.localizedString, message: TRStrings.errorOccured.localizedString)
        }
    }

    //set texts for this screen
    private func setTexts() {
        titleLabel.text = TRStrings.comments.localizedString
        sendButton.setTitle(TRStrings.send.localizedString, for: .normal)
        commentField.attributedPlaceholder = NSAttributedString(string: TRStrings.typeComment.localizedString,
                                                                attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0.6)])
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

    //Triggers on notification didSendError
    @objc private func onDidSendError(_ notification: Notification) {
        if let data = notification.userInfo as? [String: String] {
            for (_, error) in data {
                presentAlert(title: TRStrings.error.localizedString, message: error)
            }
        }
    }

    //Triggers on notification didSendComments
    @objc private func onDidSendComments(_ notification: Notification) {
        if let data = notification.userInfo as? [String: [Comment]] {
            for (_, comments) in data {
                self.comments = comments
                tableView.reloadData()
            }
        }
    }

    //Triggers on notification didRegisterComment
    @objc private func onDidRegisterComment(_ notification: Notification) {
        commentField.text = ""
        if let tid = tid {
            commentModel.getComments(tid: tid)
        } else {
            presentAlert(title: TRStrings.error.localizedString, message: TRStrings.errorOccured.localizedString)
        }
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
