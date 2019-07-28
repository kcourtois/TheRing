//
//  TRUser.swift
//  TheRing
//
//  Created by Kévin Courtois on 27/06/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

struct TRUser: Codable {
    let uid: String
    let name: String
    let gender: Gender
    let email: String
    let bio: String
}

enum Gender: Int, Codable {
    case male = 0, female = 1, other = 2

    var asString: String {
        switch self {
        case .male:
            return TRStrings.male.localizedString
        case .female:
            return TRStrings.female.localizedString
        case .other:
            return TRStrings.other.localizedString
        }
    }
}
