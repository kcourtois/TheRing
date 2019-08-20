//
//  SearchModel.swift
//  TheRing
//
//  Created by Kévin Courtois on 11/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation

class SearchModel {
    private let tournamentService: TournamentService

    init(tournamentService: TournamentService) {
        self.tournamentService = tournamentService
    }

    //get all tournaments in db and filter them with search string if provided
    func getAllTournaments(search: String? = nil) {
        if let search = search {
            tournamentService.getAllTournaments(completion: { (tournaments) in
                var tmp = [TournamentData]()
                for tournament in tournaments {
                    if tournament.title.lowercased().contains(search.lowercased()) {
                        tmp.append(tournament)
                    }
                }
                //sorts tournament form newest to oldest
                let sorted = tmp.sorted(by: { $0.startTime.compare($1.startTime) == .orderedDescending})
                self.postTournamentsNotification(tournaments: sorted)
            })
        } else {
            tournamentService.getAllTournaments(completion: { (tournaments) in
                let sorted = tournaments.sorted(by: { $0.startTime.compare($1.startTime) == .orderedDescending})
                self.postTournamentsNotification(tournaments: sorted)
            })
        }
    }

    //save user notification
    private func postTournamentsNotification(tournaments: [TournamentData]) {
        NotificationCenter.default.post(name: .didSendTournamentData, object: nil,
                                        userInfo: [NotificationStrings.didSendTournamentDataKey: tournaments])
    }
}
