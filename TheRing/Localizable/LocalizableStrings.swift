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

    init(stringLiteral value: String) {
        self.init(key: value)
    }
}

//Enum for all localized strings of the app
enum TRStrings: LocalizedString {
    //ALERT TITLES
    case saved = "SAVED"
    case error = "ERROR"
    case back = "BACK"
    case shareFailed = "SHARE_FAILED"
    case shareSucceeded = "SHARE_SUCCEEDED"
    case permissionDenied = "PERMISSION_DENIED"
    case permissionGranted = "PERMISSION_GRANTED"
    case scanNotSupported = "SCAN_NOT_SUPPORTED"
    case success = "SUCCESS"

    //ALERT MESSAGES
    case modifSaved = "MODIF_SAVED"
    case errorOccured = "ERROR_OCCURED"
    case confirmWrong = "CONFIRM_WRONG"
    case mailSelfUse = "MAIL_SELF_USE"
    case emptyFields = "EMPTY_FIELDS"
    case usernameUsed = "USERNAME_USED"
    case loading = "LOADING"
    case errorCreator = "ERROR_CREATOR"
    case failedToShare = "FAILED_TO_SHARE"
    case successShare = "SUCCESS_SHARE"
    case goToSettings = "GO_TO_SETTINGS"
    case notLogged = "NOT_LOGGED"
    case userNotRetrieved = "USER_NOT_RETRIEVED"
    case deviceNoCamera = "DEVICE_NO_CAMERA"
    case tournamentCreated = "TOURNAMENT_CREATED"
    case shareAuthorized = "SHARE_AUTHORIZED"

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
    case noAccount = "NO_ACCOUNT"
    case signUp = "SIGN_UP"
    case login = "LOGIN"
    case emailAddress = "EMAIL_ADDR"
    case password = "PASSWORD"
    case signUpDesc = "SIGNUP_DESC"
    case passwordConfirm = "PASS_CONFIRM"
    case username = "USERNAME"
    case cancel = "CANCEL"
    case continueTxt = "CONTINUE"
    case profile = "PROFILE"
    case email = "EMAIL"
    case gender = "GENDER"
    case bio = "BIO"
    case updateProfile = "UPDATE_PROFILE"
    case tournaments = "TOURNAMENTS"
    case tournament = "TOURNAMENT"
    case modEmail = "MOD_EMAIL"
    case modPass = "MOD_PASS"
    case yourUsername = "YOUR_USERNAME"
    case yourBio = "YOUR_BIO"
    case updatePassword = "UPDATE_PASS"
    case oldPassword = "OLD_PASS"
    case newPassword = "NEW_PASS"
    case confirmPass = "CONFIRM_PASS"
    case yourOldPassword = "YOUR_OLD_PASS"
    case yourNewPassword = "YOUR_NEW_PASS"
    case newPassConfirm = "NEW_PASS_CONF"
    case updateEmail = "UPDATE_MAIL"
    case newMail = "NEW_MAIL"
    case confirmMail = "CONF_MAIL"
    case yourPassword = "YOUR_PASS"
    case yourNewMail = "YOUR_MAIL"
    case newEmailConfirm = "NEW_MAIL_CONF"
    case seeTournaments = "SEE_TOURNAMENTS"
    case male = "MALE"
    case female = "FEMALE"
    case other = "OTHER"
    case home = "HOME"
    case user = "USER"
    case create = "CREATE"
    case creator = "CREATOR"
    case round = "ROUND"
    case endsOn = "ENDS_ON"
    case title = "TITLE"
    case next = "NEXT"
    case pick = "PICK"
    case createTournaments = "CREATE_TOURNAMENTS"
    case enterTitle = "ENTER_TITLE"
    case daysPerRound = "DAYS_PER_ROUND"
    case startTime = "START_TIME"
    case lastStep = "LAST_STEP"
    case comments = "COMMENTS"
    case send = "SEND"
    case pickContestant = "PICK_CONTESTANT"
    case mySubscribers = "MY_SUBSCRIBERS"
    case mySubscriptions = "MY_SUBSCRIPTIONS"
    case subscribers = "SUBSCRIBERS"
    case subscriptions = "SUBSCRIPTIONS"
    case subscribe = "SUBSCRIBE"
    case unsubscribe = "UNSUBSCRIBE"
    case settings = "SETTINGS"
    case shareTournament = "SHARE_TOURNAMENT"
    case ended = "ENDED"
    case scanner = "SCANNER"
    case search = "SEARCH"
    case logout = "LOGOUT"
    case typeComment = "TYPE_COMMENT"
    case scanCode = "SCAN_CODE"
    case addFriends = "ADD_FRIENDS"

    var localizedString: String {
        return self.rawValue.val
    }
}
