//
//  Tournament.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

//Basic tournament struct, used mostly in tournament creation
struct Tournament {
    var tid: String
    var title: String
    var description: String
    var contestants: [Movie]
    var startTime: Date
    var roundDuration: Int
    var creator: String
}
