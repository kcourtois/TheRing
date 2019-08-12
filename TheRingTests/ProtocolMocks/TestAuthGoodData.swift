//
//  TestAuthGoodData.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class TestAuthGoodData: AuthService {
    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }

    func updateEmail(password: String, mail: String, completion: @escaping (String?) -> Void) {

    }

    func updatePassword(oldPwd: String, newPwd: String, completion: @escaping (String?) -> Void) {

    }

    //Get uid for current signed in user, if any
    func getLoggedUserUID() -> String? {
        return "UID"
    }
}
