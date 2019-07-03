//
//  MovieService.swift
//  TheRing
//
//  Created by Kévin Courtois on 03/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

struct Movie {
    let title: String
    let description: String
    let imageData: Data
}

struct MovieRequest: Codable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [MovieResult]
}

struct MovieResult: Codable {
    let vote_count: String
    let id: String
    let video: String
    let vote_average: String
    let title: String
    let popularity: String
    let poster_path: String
    let original_language: String
    let original_title: String
    let genre_ids: [Int]

    let backdrop_path: String
    let adult: Bool
    let overview: String
    let release_date: String
}

class MovieService {
    static var shared = MovieService()
    private var movieSession = URLSession(configuration: .default)
    private var imageSession = URLSession(configuration: .default)
    private var task: URLSessionDataTask?
    private init() {}

    //Init used for tests
    init(movieSession: URLSession, imageSession: URLSession) {
        self.movieSession = movieSession
        self.imageSession = imageSession
    }

    //Request to TMDB API, to search a movie given a string
    func getMovies(search: String, callback: @escaping (Bool, MovieRequest?) -> Void) {

        let components = URLComponents(string: "http://api.themoviedb.org/3/search/movie")

        guard var comp = components else {
            callback(false, nil)
            return
        }

        comp.queryItems = [URLQueryItem(name: "api_key", value: ApiKeys.tmdbKey),
                           URLQueryItem(name: "query", value: search)]

        guard let url = comp.url else {
            callback(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        task?.cancel()
        task = movieSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(false, nil)
                    return
                }

                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    callback(false, nil)
                    return
                }

                guard let responseJSON = try? JSONDecoder().decode(MovieRequest.self, from: data) else {
                    callback(false, nil)
                    return
                }

                guard responseJSON.results.indices.contains(0) else {
                    callback(false, nil)
                    return
                }

                self.getImage(url: responseJSON.results[0].poster_path, completionHandler: { (data) in
                    guard let data = data else {
                        callback(false, nil)
                        return
                    }

                    let movie = Movie(title: responseJSON.results[0].title, description: responseJSON.results[0].overview, imageData: data)

                    callback(true, movie)
                })
            }
        }
        task?.resume()
    }

    //Request to Unsplash API, to get a random image for a weather keyword
    private func getImage(url: String, completionHandler: @escaping ((Data?) -> Void)) {
        guard let pictureUrl = URL(string: url) else {
            completionHandler(nil)
        }

        task?.cancel()
        task = imageSession.dataTask(with: pictureUrl) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completionHandler(nil)
                    return
                }

                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    completionHandler(nil)
                    return
                }

                completionHandler(data)
            }
        }
        task?.resume()
    }
}
