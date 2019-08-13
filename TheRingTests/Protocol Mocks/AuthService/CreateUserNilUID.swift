//
//  CreateUserNilUID.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class CreateUserNilUID: AuthService {
    func createUser(email: String, password: String, username: String,
                    completion: @escaping (String?, String?) -> Void) {
        completion(nil, nil)
    }

    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func updateEmail(password: String, mail: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func updatePassword(oldPwd: String, newPwd: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    //Get uid for current signed in user, if any
    func getLoggedUserUID() -> String? {
        return "UID"
    }
}
