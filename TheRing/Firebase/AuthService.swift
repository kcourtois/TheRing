//
//  AuthService.swifgt.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

protocol AuthService {
    //Sign in user with given credentials, returns an error or nil in completion
    func signIn(email: String, password: String, completion: @escaping (String?) -> Void)
    //Get uid for current logged user if any
    func getLoggedUserUID() -> String?
    //Updates email for current user
    func updateEmail(password: String, mail: String, completion: @escaping (String?) -> Void)
    //Updates password for current user
    func updatePassword(oldPwd: String, newPwd: String, completion: @escaping (String?) -> Void)
}