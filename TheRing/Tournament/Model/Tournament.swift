//
//  Tournament.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

struct Tournament {
    var title: String
    var description: String
    var contestants: [Movie]
    var startTime: Date
    var roundDuration: Int
    var creator: String
}
