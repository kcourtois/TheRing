//
//  SigninModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 24/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class SigninModel {
    private var userService: UserService
    private var preferences: Preferences

    init(userService: UserService, preferences: Preferences = Preferences()) {
        self.userService = userService
        self.preferences = preferences
    }

    func checkUserLogged(completion: @escaping (String?) -> Void) {
        let authService = FirebaseAuth()
        //Check if user logged
        if let uid = authService.getLoggedUserUID() {
            //Check if user pref are up to date
            if preferences.user.uid != uid {
                loadUserPref(uid: uid) { (result) in
                    completion(result)
                }
            } else {
                completion(nil)
            }
        } else {
            completion(TRStrings.userNotRetrieved.localizedString)
        }
    }

    //loads user in preferences
    private func loadUserPref(uid: String, completion: @escaping (String?) -> Void) {
        let userService = FirebaseUser()
        userService.getUserInfo(uid: uid) { (userData) in
            if let user = userData {
                self.preferences.user = user
                completion(nil)
            } else {
                completion(TRStrings.userNotRetrieved.localizedString)
            }
        }
    }
}
