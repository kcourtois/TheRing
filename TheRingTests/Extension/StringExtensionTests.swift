//
//  StringExtensionTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class StringExtensionTests: XCTestCase {
    func testGivenEmptyStringWithWhiteSpaceWhenCallingIsEmptyAfterTrimThenShouldReturnTrue() {
        XCTAssertTrue(" ".isEmptyAfterTrim)
    }

    func testGivenNotEmptyStringWithWhiteSpaceWhenCallingIsEmptyAfterTrimThenShouldReturnFalse() {
        XCTAssertFalse(" Hello ".isEmptyAfterTrim)
    }
}
