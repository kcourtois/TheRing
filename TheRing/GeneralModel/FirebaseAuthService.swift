//
//  FirebaseAuthService.swift
//  TheRing
//
//  Created by Kévin Courtois on 12/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService {
    //Updates email for current user in firebase auth. Needs to reauthenticate to proceed
    static func updateEmail(password: String, mail: String, completion: @escaping (String?) -> Void) {
        if let user = Auth.auth().currentUser {
            reauthenticate(user: user, password: password, completion: { authError in
                if authError == nil {
                    user.updateEmail(to: mail) { error in
                        completion(getAuthError(error: error))
                    }
                } else {
                    completion(authError)
                }
            })
        } else {
            completion("User not found.")
        }
    }

    //Updates password for current user in firebase auth. Needs to reauthenticate to proceed
    static func updatePassword(oldPwd: String, newPwd: String, completion: @escaping (String?) -> Void) {
        if let user = Auth.auth().currentUser {
            reauthenticate(user: user, password: oldPwd, completion: { authError in
                if authError == nil {
                    user.updatePassword(to: newPwd) { error in
                        completion(getAuthError(error: error))
                    }
                } else {
                    completion(authError)
                }
            })
        } else {
            completion("User not found.")
        }
    }

    //func to reauthenticate the current user. Requires the password to do so
    static func reauthenticate(user: User, password: String, completion: @escaping (String?) -> Void) {
        if let user = Auth.auth().currentUser {
            let preferences = Preferences()
            let cred = EmailAuthProvider.credential(withEmail: preferences.user.email, password: password)
            user.reauthenticate(with: cred, completion: { (_, error) in
                completion(getAuthError(error: error))
            })
        }
    }

    //return localized string for given error
    static func getAuthError(error: Error?) -> String? {
        guard let error = error else {
            return nil
        }
        guard let authError = AuthErrorCode(rawValue: error._code) else {
            return nil
        }
        return LocalizedString(key: authError.errorMessage).val
    }
}
