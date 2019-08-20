//
//  TournamentDateModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 12/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class TournamentDateModel {
    private let tournamentService: TournamentService

    init(tournamentService: TournamentService) {
        self.tournamentService = tournamentService
    }

    //create tournament in database with provided data in param
    func createTournament(tournament: Tournament) {
        tournamentService.createTournament(tournament: tournament) { (error) in
            if let error = error {
                self.postErrorNotification(error: error)
            } else {
                self.postDidCreateTournamentNotification()
            }
        }
    }

    //send create tournament notification
    private func postDidCreateTournamentNotification() {
        NotificationCenter.default.post(name: .didCreateTournament, object: nil,
                                        userInfo: [NotificationStrings.didCreateTournamentKey:
                                                   NotificationStrings.didCreateTournamentKey])
    }

    //send error notification
    private func postErrorNotification(error: String) {
        NotificationCenter.default.post(name: .didSendError, object: nil,
                                        userInfo: [NotificationStrings.didSendErrorKey: error])
    }
}
