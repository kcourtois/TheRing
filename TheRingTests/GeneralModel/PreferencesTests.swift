//
//  PreferencesTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 07/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing

class PreferencesTests: XCTestCase {
    var preferences: Preferences!

    override func setUp() {
        preferences = Preferences(defaults: .makeClearedInstance())
    }

    func testGivenEmptyUserdefaultsThenShouldReturnUnknownUser() {
        XCTAssertEqual(preferences.user.uid, "Unknown")
        XCTAssertEqual(preferences.user.name, "Unknown")
        XCTAssertEqual(preferences.user.gender, .other)
        XCTAssertEqual(preferences.user.email, "Unknown")
        XCTAssertEqual(preferences.user.bio, "Unknown")
    }

    func testGivenUserdefaultsFilledThenShouldReturnCorrespondingUser() {
        preferences.user = TRUser(uid: "123456", name: "Toto", gender: .male, email: "toto@gmail.com", bio: "nothing")
        XCTAssertEqual(preferences.user.uid, "123456")
        XCTAssertEqual(preferences.user.name, "Toto")
        XCTAssertEqual(preferences.user.gender, .male)
        XCTAssertEqual(preferences.user.email, "toto@gmail.com")
        XCTAssertEqual(preferences.user.bio, "nothing")
    }
}
