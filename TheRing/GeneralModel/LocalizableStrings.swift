//
//  LocalizedStrings.swift
//  TheRing
//
//  Created by Kévin Courtois on 05/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

struct LocalizedString: ExpressibleByStringLiteral, Equatable {

    let val: String

    init(key: String) {
        self.val = NSLocalizedString(key, comment: "")
    }
    init(localized: String) {
        self.val = localized
    }
    init(stringLiteral value: String) {
        self.init(key: value)
    }
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(key: value)
    }
    init(unicodeScalarLiteral value: String) {
        self.init(key: value)
    }
}

enum TRStrings: LocalizedString {
    case saved = "SAVED"
    case error = "ERROR"

    case modifSaved = "MODIF_SAVED"
    case errorOccured = "ERROR_OCCURED"
    case confirmWrong = "CONFIRM_WRONG"
    case mailSelfUse = "MAIL_SELF_USE"
    case emptyFields = "EMPTY_FIELDS"
    case usernameUsed = "USERNAME_USED"
    case loading = "LOADING"

    //FIREBASE AUTH ERROR
    case mailUsed = "MAIL_USED"
    case accountNotFound = "ACCOUNT_NOT_FOUND"
    case accountDisabled = "ACCOUNT_DISABLED"
    case wrongMail = "WRONG_MAIL"
    case networkError = "NETWORK_ERROR"
    case weakPassword = "WEAK_PASSWORD"
    case wrongPassword = "WRONG_PASSWORD"

    //Movie genres
    case action = "ACTION"
    case adventure = "ADVENTURE"
    case animation = "ANIMATION"
    case comedy = "COMEDY"
    case crime = "CRIME"
    case documentary = "DOCUMENTARY"
    case drama = "DRAMA"
    case family = "FAMILY"
    case fantasy = "FANTASY"
    case history = "HISTORY"
    case horror = "HORROR"
    case music = "MUSIC"
    case mystery = "MYSTERY"
    case romance = "ROMANCE"
    case scifi = "SCIFI"
    case tvMovie = "TV_MOVIE"
    case thriller = "THRILLER"
    case war = "WAR"
    case western = "WESTERN"

    //UI
    case enterDescription = "ENTER_DESCRIPTION"
    case selectContestant = "SELECT_CONTESTANT"
    case contestant = "CONTESTANT"
    case overview = "OVERVIEW"
    case releaseDate = "RELEASE_DATE"
    case category = "CATEGORY"
    case rating = "RATING"
    case roundDays = "ROUND_DAYS"

    var localizedString: String {
        return self.rawValue.val
    }

    init?(localizedString: String) {
        self.init(rawValue: LocalizedString(localized: localizedString))
    }
}

//let option1 = DietWithoutResidueOption.saved
//let option2 = DietWithoutResidueOption(rawValue: "SAVED") // as Optional
//let option3 = DietWithoutResidueOption(localizedString: "Sauvegardé")
//let option4 = DietWithoutResidueOption(localizedString: "Saved")
//print(option1)
//print(option2)
//print(option3)
//print(option4)
//print(option1.localizedString)
//print(option2?.localizedString)
//print(option3?.localizedString)
//print(option4?.localizedString)

//saved
//Optional(TheRing.DietWithoutResidueOption.saved)
//Optional(TheRing.DietWithoutResidueOption.saved)
//nil
//Sauvegardé
//Optional("Sauvegardé")
//Optional("Sauvegardé")
//nil
