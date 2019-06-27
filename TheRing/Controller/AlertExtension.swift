//
//  AlertExtension.swift
//  TheRing
//
//  Created by Kévin Courtois on 26/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

extension UIViewController {
    //Creates an alert with a title and a message
    func presentAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

    //Creates an alert with a title and a message that stays on screen for given delay
    func presentAlertDelay(title: String, message: String, delay: Double, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
            completion()
        }
    }

    //Creates an alert with an activity indicator (loading screen), and returns it to dismiss later
    func loadingAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.startAnimating()
        alert.view.addSubview(activityIndicator)
        present(alert, animated: true, completion: nil)
        return alert
    }

    //dismiss alert before presenting new one
    func dismissLoadAlertWithMessage(alert: UIAlertController?, title: String, message: String) {
        if let alert = alert {
            alert.dismiss(animated: true) {
                self.presentAlert(title: title, message: message)
            }
        } else {
            self.presentAlert(title: title, message: message)
        }
    }
}
