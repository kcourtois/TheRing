//
//  UserManager.swift
//  TheRing
//
//  Created by Kévin Courtois on 27/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class Preferences {

    private struct Keys {
        static let user = "user"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var user: User {
        get {
            guard let data = defaults.value(forKey: Keys.user) as? Data else {
                return User(uid: "", name: "", gender: .other, email: "", bio: "")
            }
            guard let res = try? JSONDecoder().decode(User.self, from: data) else {
                return User(uid: "", name: "", gender: .other, email: "", bio: "")
            }
            return res
        }
        set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: Keys.user)
        }
    }
}
