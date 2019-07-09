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
            let release = "2019-04-24"
            let image = "https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg"

            XCTAssertEqual(title, result?[0].title)
            XCTAssertEqual(release, result?[0].release_date)
            XCTAssertEqual(image, result?[0].image)

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 0.01)
    }
}
