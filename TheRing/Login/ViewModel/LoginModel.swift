//
//  LoginModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 11/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class LoginModel {
    private var authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    //check if a user is aleady logged
    func alearyLogged() -> Bool {
        return authService.getLoggedUserUID() != nil
    }

    //try to sign in user with given credentials, and sends a notification for success or error
    func signIn(email: String, password: String) {
        authService.signIn(email: email, password: password) { (error) in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.postSignInNotification()
            }
        }
    }

    //send sign in notification
    private func postSignInNotification() {
        NotificationCenter.default.post(name: .didSignIn, object: nil,
                                        userInfo: [NotificationStrings.didSignInKey:
                                            NotificationStrings.didSignInKey])
    }

    //send error notification
    private func postErrorNotification(error: String) {
        NotificationCenter.default.post(name: .didSendError, object: nil,
                                        userInfo: [NotificationStrings.didSendErrorKey:
                                            error])
    }
}
