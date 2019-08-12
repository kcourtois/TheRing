//
//  TestAuth.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing

class TestAuthBadData: AuthService {
    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    func updateEmail(password: String, mail: String, completion: @escaping (String?) -> Void) {

    }

    func updatePassword(oldPwd: String, newPwd: String, completion: @escaping (String?) -> Void) {

    }

    //Get uid for current signed in user, if any
    func getLoggedUserUID() -> String? {
        return nil
    }
}
