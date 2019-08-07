//
//  Genre.swift
//  TheRing
//
//  Created by Kévin Courtois on 10/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

//Genres matching TMDB API
enum Genre: Int {
    case action = 28
    case adventure = 12
    case animation = 16
    case comedy = 35
    case crime = 80
    case documentary = 99
    case drama = 18
    case family = 10751
    case fantasy = 14
    case history = 36
    case horror = 27
    case music = 10402
    case mystery = 9648
    case romance = 10749
    case scifi = 878
    case tvMovie = 10770
    case thriller = 53
    case war = 10752
    case western = 37

    var localizedString: String {
        switch self {
        case .action:
            return TRStrings.action.localizedString
        case .adventure:
            return TRStrings.adventure.localizedString
        case .animation:
            return TRStrings.animation.localizedString
        case .comedy:
            return TRStrings.comedy.localizedString
        case .crime:
            return TRStrings.crime.localizedString
        case .documentary:
            return TRStrings.documentary.localizedString
        case .drama:
            return TRStrings.drama.localizedString
        case .family:
            return TRStrings.family.localizedString
        case .fantasy:
            return TRStrings.fantasy.localizedString
        case .history:
            return TRStrings.history.localizedString
        case .horror:
            return TRStrings.horror.localizedString
        case .music:
            return TRStrings.music.localizedString
        case .mystery:
            return TRStrings.mystery.localizedString
        case .romance:
            return TRStrings.romance.localizedString
        case .scifi:
            return TRStrings.scifi.localizedString
        case .tvMovie:
            return TRStrings.tvMovie.localizedString
        case .thriller:
            return TRStrings.thriller.localizedString
        case .war:
            return TRStrings.war.localizedString
        case .western:
            return TRStrings.western.localizedString
        }
    }
}
