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
            movieSession: URLSessionFake(data: nil, response: nil, error: FakeResponseData.error))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovies(search: "avengers", callback: { (success, movie) in
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
            movieSession: URLSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovies(search: "avengers", callback: { (success, movie) in
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
                error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovies(search: "avengers", callback: { (success, movie) in
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
                error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovies(search: "avengers", callback: { (success, movie) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(movie)
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
                error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        movieService.getMovies(search: "avengers", callback: { (success, result) in
            // Then
            XCTAssertTrue(success)
            XCTAssertNotNil(result)

            let title = "Avengers: Endgame"
            //swiftlint:disable:next line_length
            let description = "After the devastating events of Avengers: Infinity War, the universe is in ruins due to the efforts of the Mad Titan, Thanos. With the help of remaining allies, the Avengers must assemble once more in order to undo Thanos' actions and restore order to the universe once and for all, no matter what consequences may be in store."
            let image = "/or06FN3Dka5tukK1e9sl16pB3iy.jpg"

            XCTAssertEqual(title, result?[0].title)
            XCTAssertEqual(description, result?[0].description)
            XCTAssertEqual(image, result?[0].image)

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 0.01)
    }
}
