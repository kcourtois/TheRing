//
//  MovieService.swift
//  TheRing
//
//  Created by Kévin Courtois on 03/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

struct MovieRequest: Codable {
    let page: Int
    //swiftlint:disable:next identifier_name
    let total_results: Int
    //swiftlint:disable:next identifier_name
    let total_pages: Int
    let results: [Movie]
}

struct Movie: Codable {
    //swiftlint:disable:next identifier_name
    let vote_count: Int
    //swiftlint:disable:next identifier_name
    let id: Int
    let video: Bool
    //swiftlint:disable:next identifier_name
    let vote_average: Double
    let title: String
    let popularity: Double
    //swiftlint:disable:next identifier_name
    let poster_path: String?
    //swiftlint:disable:next identifier_name
    let original_language: String

    //swiftlint:disable:next identifier_name
    let original_title: String
    //swiftlint:disable:next identifier_name
    let genre_ids: [Int]
    //swiftlint:disable:next identifier_name
    let backdrop_path: String?
    let adult: Bool
    let overview: String
    //swiftlint:disable:next identifier_name
    let release_date: String

    var image: String {
        return "https://image.tmdb.org/t/p/w500\(poster_path ?? "")"
    }
}

class MovieService {
    private var movieSession: URLSession
    private var task: URLSessionDataTask?

    //Init used for tests
    init(movieSession: URLSession = URLSession(configuration: .default)) {
        self.movieSession = movieSession
    }

    //Request to TMDB API, to search a movie given a string
    func getMovies(search: String = "", callback: @escaping (Bool, [Movie]?) -> Void) {

        var components: URLComponents?
        //if search string is empty, get trending movie list
        if search.isEmpty {
            components = URLComponents(string: "https://api.themoviedb.org/3/trending/movie/day")
        } else {
            //else search the movie
            components = URLComponents(string: "https://api.themoviedb.org/3/search/movie")
        }

        guard var comp = components else {
            callback(false, nil)
            return
        }

        comp.queryItems = [URLQueryItem(name: "api_key", value: ApiKeys.tmdbKey),
                           URLQueryItem(name: "language", value: NSLocale.preferredLanguages[0])]
        if !search.isEmpty {
            comp.queryItems?.append(URLQueryItem(name: "query", value: search))
        }

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

                var movies = [Movie]()
                for res in responseJSON.results where res.poster_path != nil {
                    movies.append(res)
                }
                callback(true, movies)
            }
        }
        task?.resume()
    }
}
