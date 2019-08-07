//
//  UserInfo.swift
//  
//
//  Created by Kévin Courtois on 01/08/2019.
//

import UIKit

class UserInfoView: UIView {

    @IBOutlet weak var usernameDesc: UILabel!
    @IBOutlet weak var emailDesc: UILabel!
    @IBOutlet weak var genderDesc: UILabel!
    @IBOutlet weak var bioDesc: UILabel!
    @IBOutlet weak var subscribersDesc: UILabel!
    @IBOutlet weak var subscriptionsDesc: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var subscriptionsLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        //set texts for this screen
        setTexts()
        //set tap gestures on labels to send notifications
        setNotifications()
    }

    //Initalisation of the xib
    func commonInit() {
        //Load xib by name
        let contentView = Bundle.main.loadNibNamed(selfName(), owner: self, options: nil)?.first as? UIView ?? UIView()
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)
    }

    //called by owner view, to set user details
    func setUser(user: TRUser) {
            mailLabel.text = user.email
            nameLabel.text = user.name
            genderLabel.text = user.gender.asString
            biographyLabel.text = user.bio
    }

    //called by owner view, to set user subscriptions count
    func setSubscriptionsCount(count: UInt) {
        subscriptionsLabel.text = "\(count)"
    }

    //called by owner view, to set user subscribers count
    func setSubscribersCount(count: UInt) {
        subscribersLabel.text = "\(count)"
    }

    //set texts for this screen
    private func setTexts() {
        usernameDesc.text = TRStrings.username.localizedString
        emailDesc.text = TRStrings.email.localizedString
        genderDesc.text = TRStrings.gender.localizedString
        bioDesc.text = TRStrings.bio.localizedString
        subscribersDesc.text = TRStrings.subscribers.localizedString
        subscriptionsDesc.text = TRStrings.subscriptions.localizedString
    }

    //set tap gestures on labels to send notifications
    private func setNotifications() {
        //add tap detection for subscriptions
        subscriptionsDesc.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action: #selector(subscriptionsNotification)))
        subscriptionsDesc.isUserInteractionEnabled = true
        subscriptionsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                       action: #selector(subscriptionsNotification)))
        subscriptionsLabel.isUserInteractionEnabled = true
        //add tap detection for subscribers
        subscribersLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(subscribersNotification)))
        subscribersLabel.isUserInteractionEnabled = true
        subscribersDesc.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                    action: #selector(subscribersNotification)))
        subscribersDesc.isUserInteractionEnabled = true
    }

    //Get class name and turn it to a string
    private func selfName() -> String {
        let thisType = type(of: self)
        return String(describing: thisType)
    }

    //send notification for subscriptions button tapped
    @objc func subscriptionsNotification() {
        let name = Notification.Name(rawValue: NotificationStrings.didTapSubscriptionsNotificationName)
        NotificationCenter.default.post(name: name, object: nil,
                                        userInfo: [NotificationStrings.didTapSubscriptionsParameterKey:
                                            NotificationStrings.didTapSubscriptionsParameterKey])
    }

    //send notification for subscribers button tapped
    @objc func subscribersNotification() {
        let name = Notification.Name(rawValue: NotificationStrings.didTapSubscribersNotificationName)
        NotificationCenter.default.post(name: name, object: nil,
                                        userInfo: [NotificationStrings.didTapSubscribersParameterKey:
                                            NotificationStrings.didTapSubscribersParameterKey])
    }
}