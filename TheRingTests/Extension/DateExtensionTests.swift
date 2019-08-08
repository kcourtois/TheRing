//
//  DateExtensionTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 08/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import XCTest
@testable import TheRing
import Foundation

class DateExtensionTests: XCTestCase {

    override func setUp() {
        NSTimeZone.default = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
    }

    func testGivenADateWhenCallingDateToStringThenShouldReturnFormattedString() {
        let refDate = Date(timeIntervalSince1970: 2682120)

        XCTAssertNotNil(refDate.dateToString())
        XCTAssertEqual(refDate.dateToString()!, "1970-02-01 01:02 AM")
    }

    func testGivenFormatedStringWhenInitDateStringHMThenShouldReturnDate() {
        let refDate = Date(timeIntervalSince1970: 2682120)
        let refString = "1970-02-01 01:02 AM"

        let testDate = Date(dateStringWithHM: refString)

        XCTAssertNotNil(testDate)
        XCTAssertEqual(refDate, testDate)
    }

    func testGivenBadStringWhenInitDateStringHMThenShouldReturnNil() {
        let refString = "XXXX"

        let testDate = Date(dateStringWithHM: refString)

        XCTAssertNil(testDate)
    }

    func testGivenFormatedStringWhenInitDateStringThenShouldReturnDate() {
        let refDate = Date(timeIntervalSince1970: 2678400)
        let refString = "1970-02-01"

        let testDate = Date(dateString: refString)

        XCTAssertNotNil(testDate)
        XCTAssertEqual(refDate, testDate)
    }

    func testGivenBadStringWhenInitDateStringThenShouldReturnNil() {
        let refString = "XXXX"

        let testDate = Date(dateString: refString)

        XCTAssertNil(testDate)
    }

    func testGivenLocalENWhenCallingDateLocalizedThenStringShouldBeLocalized() {
        let locale = Locale.init(identifier: "en_EN")
        let refDate = Date(timeIntervalSince1970: 2682120)
        let refString = "2/1/70, 1:02 AM"

        let resString = refDate.dateToLocalizedString(locale: locale)

        XCTAssertEqual(refString, resString)
    }

    func testGivenLocalFRWhenCallingDateLocalizedThenStringShouldBeLocalized() {
        let locale = Locale.init(identifier: "fr_FR")
        let refDate = Date(timeIntervalSince1970: 2682120)
        let refString = "01/02/1970 01:02"
        let resString = refDate.dateToLocalizedString(locale: locale)

        XCTAssertEqual(refString, resString)
    }
}
