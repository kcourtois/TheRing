//
//  StringExtension.swift
//  TheRing
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

extension String {
    var isEmptyAfterTrim: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
