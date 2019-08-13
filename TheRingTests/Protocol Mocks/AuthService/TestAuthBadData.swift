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
    func createUser(email: String, password: String, username: String,
                    completion: @escaping (String?, String?) -> Void) {
        completion(nil, TRStrings.errorOccured.localizedString)
    }

    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    func updateEmail(password: String, mail: String, completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    func updatePassword(oldPwd: String, newPwd: String, completion: @escaping (String?) -> Void) {
        completion(TRStrings.errorOccured.localizedString)
    }

    //Get uid for current signed in user, if any
    func getLoggedUserUID() -> String? {
        return nil
    }
}
