//
//  UserDefaultsExtension.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 08/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

//Extends UserDefaults to use easily empty ones in tests
extension UserDefaults {
    static func makeClearedInstance(
        for functionName: StaticString = #function,
        inFile fileName: StaticString = #file
        ) -> UserDefaults {
        let className = "\(fileName)".split(separator: ".")[0]
        let testName = "\(functionName)".split(separator: "(")[0]
        let suiteName = "com.kcourtois.test.\(className).\(testName)"

        let defaults = self.init(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
