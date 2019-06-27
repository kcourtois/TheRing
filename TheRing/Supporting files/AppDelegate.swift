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

//        //Skip login page if user signed in
//        if Auth.auth().currentUser != nil {
//            let mainStoryboardIpad: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let initialViewControlleripad: UIViewController =
//                mainStoryboardIpad.instantiateViewController(withIdentifier: "Tabbar") as UIViewController
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            self.window?.rootViewController = initialViewControlleripad
//            self.window?.makeKeyAndVisible()
//        }

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
