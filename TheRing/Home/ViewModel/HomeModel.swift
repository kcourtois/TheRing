//
//  HomeModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 11/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class HomeModel {
    private let authService: AuthService
    private let userService: UserService
    private let tournamentService: TournamentService
    private let preferences: Preferences

    init(authService: AuthService, userService: UserService, tournamentService: TournamentService,
         preferences: Preferences = Preferences()) {
        self.authService = authService
        self.userService = userService
        self.tournamentService = tournamentService
        self.preferences = preferences
    }

    func getUserTournaments() {
        tournamentService.getUserTournamentsWithData(completion: { (tournaments) in
            //sort tournaments from most recent to oldest
            let sorted = tournaments.sorted(by: { $0.startTime.compare($1.startTime) == .orderedDescending})
            self.postTournamentDataNotification(data: sorted)
        })
    }

    //send error notification
    private func postTournamentDataNotification(data: [TournamentData]) {
        NotificationCenter.default.post(name: .didSendTournamentData, object: nil,
                                        userInfo: [NotificationStrings.didSendTournamentDataKey: data])
    }
}
