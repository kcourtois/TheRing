//
//  AppDelegate.swift
//  TheRing
//
//  Created by Kévin Courtois on 17/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Config firebase
        FirebaseApp.configure()
        //Dark keyboard for all textfields
        UITextField.appearance().keyboardAppearance = .dark
        //Red selected color for tableviews
        let colorView = UIView()
        colorView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        UITableViewCell.appearance().selectedBackgroundView = colorView

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
