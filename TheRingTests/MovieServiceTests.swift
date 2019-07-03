//
//  MovieServiceTests.swift
//  TheRingTests
//
//  Created by Kévin Courtois on 03/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
@testable import TheRing
import XCTest

class MovieTests: XCTestCase {

    func testGetMovieShouldPostFailedCallback() {
        // Given
        let movieService = MovieService(
            movieSession: URLSessionFake(data: nil, response: nil, error: FakeResponseData.error),
            imageSession: URLSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovie(search: "avengers", callback: { (success, movie) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(movie)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetMovieShouldPostFailedCallbackIfNoData() {
        // Given
        let movieService = MovieService(
            movieSession: URLSessionFake(data: nil, response: nil, error: nil),
            imageSession: URLSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovie(search: "avengers", callback: { (success, movie) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(movie)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetMovieShouldPostFailedCallbackIfIncorrectResponse() {
        // Given
        let movieService = MovieService(
            movieSession: URLSessionFake(
                data: FakeResponseData.movieCorrectData,
                response: FakeResponseData.responseKO,
                error: nil),
            imageSession: URLSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovie(search: "avengers", callback: { (success, movie) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(movie)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetMovieShouldPostFailedCallbackIfIncorrectData() {
        // Given
        let movieService = MovieService(
            movieSession: URLSessionFake(
                data: FakeResponseData.incorrectData,
                response: FakeResponseData.responseOK,
                error: nil),
            imageSession: URLSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovie(search: "avengers", callback: { (success, movie) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(movie)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetMovieShouldPostFailedNotificationIfNoPictureData() {
        // Given
        let movieService = MovieService(
            movieSession: URLSessionFake(
                data: FakeResponseData.movieCorrectData,
                response: FakeResponseData.responseOK,
                error: nil),
            imageSession: URLSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovie(search: "avengers", callback: { (success, result) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(result)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetMovieShouldPostFailedNotificationIfErrorWhileRetrievingPicture() {
        // Given
        let movieService = MovieService(
            movieSession: URLSessionFake(
                data: FakeResponseData.movieCorrectData,
                response: FakeResponseData.responseOK,
                error: nil),
            imageSession: URLSessionFake(
                data: FakeResponseData.imageData,
                response: FakeResponseData.responseOK,
                error: FakeResponseData.error))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovie(search: "avengers", callback: { (success, result) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(result)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetMovieShouldPostFailedNotificationIfIncorrectResponseWhileRetrievingPicture() {
        // Given
        let movieService = MovieService(
            movieSession: URLSessionFake(
                data: FakeResponseData.movieCorrectData,
                response: FakeResponseData.responseOK,
                error: nil),
            imageSession: URLSessionFake(
                data: FakeResponseData.imageData,
                response: FakeResponseData.responseKO,
                error: FakeResponseData.error))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovie(search: "avengers", callback: { (success, result) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(result)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetMovieShouldPostSuccessCallbackIfNoErrorAndCorrectData() {
        // Given
        let movieService = MovieService(
            movieSession: URLSessionFake(
                data: FakeResponseData.movieCorrectData,
                response: FakeResponseData.responseOK,
                error: nil),
            imageSession: URLSessionFake(
                data: FakeResponseData.imageData,
                response: FakeResponseData.responseOK,
                error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovie(search: "avengers", callback: { (success, result) in
            // Then
            XCTAssertTrue(success)
            XCTAssertNotNil(result)

            let title = "Avengers: Endgame"
            let description = "After the devastating events of Avengers: Infinity War, the universe is in ruins due to the efforts of the Mad Titan, Thanos. With the help of remaining allies, the Avengers must assemble once more in order to undo Thanos' actions and restore order to the universe once and for all, no matter what consequences may be in store."
            let image: Data = "image".data(using: .utf8)!

            XCTAssertEqual(city, result?.title)
            XCTAssertEqual(movie, result?.movie)
            XCTAssertEqual(image, result?.image)

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 0.01)
    }
}
