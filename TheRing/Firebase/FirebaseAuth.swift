//
//  FirebaseAuth.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuth: AuthService {

    //Get uid for current signed in user, if any
    func getLoggedUserUID() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid
        } else {
            return nil
        }
    }

    //Sign in user with given credentials, returns an error or nil in completion
    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            completion(self.getAuthError(error: error))
        }
    }

    //Updates email for current user in firebase auth. Needs to reauthenticate to proceed
    func updateEmail(password: String, mail: String, completion: @escaping (String?) -> Void) {
        if let user = Auth.auth().currentUser {
            reauthenticate(user: user, password: password, completion: { authError in
                if authError == nil {
                    user.updateEmail(to: mail) { error in
                        completion(self.getAuthError(error: error))
                    }
                } else {
                    completion(authError)
                }
            })
        } else {
            completion(TRStrings.errorOccured.localizedString)
        }
    }

    //Updates password for current user in firebase auth. Needs to reauthenticate to proceed
    func updatePassword(oldPwd: String, newPwd: String, completion: @escaping (String?) -> Void) {
        if let user = Auth.auth().currentUser {
            reauthenticate(user: user, password: oldPwd, completion: { authError in
                if authError == nil {
                    user.updatePassword(to: newPwd) { error in
                        completion(self.getAuthError(error: error))
                    }
                } else {
                    completion(authError)
                }
            })
        } else {
            completion(TRStrings.errorOccured.localizedString)
        }
    }

    //func to reauthenticate the current user. Requires the password to do so
    private func reauthenticate(user: User, password: String, completion: @escaping (String?) -> Void) {
        if let user = Auth.auth().currentUser {
            let preferences = Preferences()
            let cred = EmailAuthProvider.credential(withEmail: preferences.user.email, password: password)
            user.reauthenticate(with: cred, completion: { (_, error) in
                completion(self.getAuthError(error: error))
            })
        }
    }

    //return localized string for given error
    private func getAuthError(error: Error?) -> String? {
        guard let error = error else {
            return nil
        }
        guard let authError = AuthErrorCode(rawValue: error._code) else {
            return nil
        }
        return LocalizedString(key: authError.errorMessage).val
    }
}
