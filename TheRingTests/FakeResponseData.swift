//
//  FakeResponseData.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 03/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class FakeResponseData {
    // MARK: - Data

    static var movieCorrectData: Data? {
        let bundle = Bundle(for: FakeResponseData.self)
        let url = bundle.url(forResource: "Movie", withExtension: "json")!
        // swiftlint:disable:next force_try
        return try! Data(contentsOf: url)
    }

    static let incorrectData = "erreur".data(using: .utf8)!
    static let imageData = "image".data(using: .utf8)!

    // MARK: - Response
    static let responseOK = HTTPURLResponse(
        url: URL(string: "http://www.test.com/api/")!,
        statusCode: 200, httpVersion: nil, headerFields: [:])!

    static let responseKO = HTTPURLResponse(
        url: URL(string: "http://www.test.com/api/")!,
        statusCode: 500, httpVersion: nil, headerFields: [:])!
}
