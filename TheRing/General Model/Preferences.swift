//
//  UserManager.swift
//  TheRing
//
//  Created by Kévin Courtois on 27/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

//Preferences interacts with userdefaults to store the user profile on the phone
class Preferences {

    private struct Keys {
        static let user = "user"
    }

    private let defaults: UserDefaults

    //default init is standard
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    //access preferences storage and read with this var
    public var user: TRUser {
        get {
            guard let data = defaults.value(forKey: Keys.user) as? Data else {
                return TRUser(uid: "Unknown", name: "Unknown", gender: .other, email: "Unknown", bio: "Unknown")
            }
            guard let res = try? JSONDecoder().decode(TRUser.self, from: data) else {
                return TRUser(uid: "Unknown", name: "Unknown", gender: .other, email: "Unknown", bio: "Unknown")
            }
            return res
        }
        set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: Keys.user)
        }
    }
}
