//
//  FirebaseTournament.swift
//  TheRing
//
//  Created by Kévin Courtois on 09/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth.FIRAuthErrors

//Implements TournamentService to fetch data with firebase
class FirebaseTournament: TournamentService {

    private let userService: UserService = FirebaseUser()

    //create a tournament with given parameters
    func createTournament(tournament: Tournament, completion: @escaping (String?) -> Void) {
        let tid = generateId()

        //puts start time as a string
        guard let startTime = getEndDate(duration: 0, start: tournament.startTime) else {
            completion(TRStrings.errorOccured.localizedString)
            return
        }

        let values = ["title": tournament.title, "description": tournament.description,
                      "startTime": startTime, "creator": tournament.creator]

        registerTournament(tid: tid, values: values, tournament: tournament) { error in
            completion(error)
        }
    }

    //returns a list of tournaments created by current user (with all the datas)
    func getUserTournamentsWithData(completion: @escaping ([TournamentData]) -> Void) {
        var tournaments = [TournamentData]()
        let reference = Database.database().reference()
        let preferences = Preferences()
        let group = DispatchGroup()
        group.enter()
        reference.child("user_tournaments").child(preferences.user.uid).observeSingleEvent(of: .value,
                                                                                           with: { (snapshot) in
            //for all tids found (for current user)
            for case let data as DataSnapshot in snapshot.children {
                group.enter()
                if let tid = data.value as? String {
                    //get tournament data
                    self.getTournamentFull(tid: tid, completion: { (tournament) in
                        if let tournament = tournament {
                            tournaments.append(tournament)
                            group.leave()
                        }
                    })
                }
            }
            group.leave()
        })
        group.notify(queue: .main) {
            completion(tournaments)
        }
    }

    //returns a list of tournaments created by current user
    func getAllTournaments(completion: @escaping ([TournamentData]) -> Void) {
        var tournaments = [TournamentData]()
        let reference = Database.database().reference()
        let group = DispatchGroup()
        group.enter()
        reference.child("tournaments").observeSingleEvent(of: .value, with: { (snapshot) in
            //for all tids found
            for case let data as DataSnapshot in snapshot.children {
                group.enter()
                //get tournament data
                self.getTournamentFull(tid: data.key, completion: { (tournament) in
                    if let tournament = tournament {
                        tournaments.append(tournament)
                        group.leave()
                    }
                })
            }
            group.leave()
        })
        group.notify(queue: .main) {
            completion(tournaments)
        }
    }

    //returns tournament data from tid (without rounds and matches)
    func getTournament(tid: String, completion: @escaping (Tournament?) -> Void) {
        let reference = Database.database().reference()
        reference.child("tournaments").child(tid).observeSingleEvent(of: .value, with: { (snapshot) in
            //get all keys as variables
            let value = snapshot.value as? NSDictionary
            if let title = value?["title"] as? String,
                let description = value?["description"] as? String,
                let startTime = value?["startTime"] as? String,
                let creator = value?["creator"] as? String {
                //converts the date from string to date type
                if let date = Date(dateStringWithHM: startTime) {
                    completion(Tournament(tid: tid, title: title, description: description, contestants: [],
                                          startTime: date, roundDuration: 0, creator: creator))
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        })
    }

    //returns tournament data from tid
    func getTournamentFull(tid: String, completion: @escaping (TournamentData?) -> Void) {
        getTournament(tid: tid) { (tournament) in
            if let tournament = tournament {
                self.getContestants(tid: tid, completion: { (contestants) in
                    self.getRounds(tid: tid, completion: { (rounds) in
                        self.userService.getUserInfo(uid: tournament.creator, completion: { (user) in
                            if let user = user {
                                let comp = TournamentData(tid: tid, title: tournament.title,
                                                          description: tournament.description,
                                                          creator: user, startTime: tournament.startTime,
                                                          rounds: rounds, contestants: contestants)
                                completion(comp)
                            } else {
                                completion(nil)
                            }
                        })
                    })
                })
            } else {
                completion(nil)
            }
        }
    }

    //returns rounds for a tournament
    func getRounds(tid: String, completion: @escaping ([Round]) -> Void) {
        let reference = Database.database().reference()
        var rounds = [Round]()
        let group = DispatchGroup()
        group.enter()
        reference.child("rounds").child(tid).observeSingleEvent(of: .value, with: { (snapshot) in
            //for each round in the given tid
            for case let data as DataSnapshot in snapshot.children {
                //transform values as variables
                let value = data.value as? NSDictionary
                if let endDate = value?["endDate"] as? String {
                    //gets date from string to date type
                    if let end = Date(dateStringWithHM: endDate) {
                        //add the round
                        rounds.append(Round(rid: data.key, endDate: end))
                    }
                }
            }
            group.leave()
        })
        group.notify(queue: .main) {
            //sort rounds by date in completion
            completion(rounds.sorted(by: { $0.endDate.compare($1.endDate) == .orderedAscending}))
        }
    }

    //returns contestant data
    func getContestant(tid: String, cid: String, completion: @escaping (Contestant?) -> Void) {
        let reference = Database.database().reference()
        reference.child("contestants").child(tid).child(cid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let name = value?["name"] as? String,
                let image = value?["image"] as? String {
                completion(Contestant(cid: cid, image: image, name: name))
            } else {
                completion(nil)
            }
        })
    }

    //returns all contestants from a tid
    func getContestants(tid: String, completion: @escaping ([Contestant]) -> Void) {
        let reference = Database.database().reference()
        var contestants = [Contestant]()
        let group = DispatchGroup()
        group.enter()
        reference.child("contestants").child(tid).observeSingleEvent(of: .value, with: { (snapshot) in
            //for each contestant in given tid, get the values to var
            for case let data as DataSnapshot in snapshot.children {
                let value = data.value as? NSDictionary
                if let image = value?["image"] as? String, let name = value?["name"] as? String {
                    contestants.append(Contestant(cid: data.key, image: image, name: name))
                }
            }
            group.leave()
        })
        group.notify(queue: .main) {
            completion(contestants)
        }
    }

    //register a tournament for the given user (creator)
    private func registerUserTournament(tid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let preferences = Preferences()
        let values = [tid: tid]
        reference.child("user_tournaments").child(preferences.user.uid)
                                           .updateChildValues(values,
                                                              withCompletionBlock: { (error, _) in
            completion(self.getAuthError(error: error))
        })
    }

    //register tournament informations
    private func registerTournament(tid: String, values: [String: String], tournament: Tournament,
                                    completion: @escaping (String?) -> Void) {
        //create tournament
        let reference = Database.database().reference()
        reference.child("tournaments").child(tid).updateChildValues(values, withCompletionBlock: { (error, _) in
            if let error = error {
                completion(self.getAuthError(error: error))
                return
            }

            var cids = [String]()
            //create contestants
            for contestant in tournament.contestants {
                let cid = self.generateId()
                cids.append(cid)
                self.registerContestant(tid: tid, cid: cid, contestant: contestant, completion: { (error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                })
            }

            //create rounds
            let roundQt = self.getNumberOfRounds(contestants: tournament.contestants.count)
            var rids = [String]()
            for index in 1...roundQt {
                let rid = self.generateId()
                rids.append(rid)
                guard let endDate = self.getEndDate(duration: tournament.roundDuration*index,
                                               start: tournament.startTime) else {
                                                completion(TRStrings.errorOccured.localizedString)
                                                return
                }
                self.registerRound(tid: tid, rid: rid, endDate: endDate, completion: { (error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                })
            }

            //registers tournament in the list of the user
            self.registerUserTournament(tid: tid) { error in
                if let error = error {
                    completion(error)
                    return
                }
                completion(nil)
            }
        })
    }

    //registers a round in the database
    private func registerRound(tid: String, rid: String, endDate: String,
                               completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let values = ["endDate": endDate]
        reference.child("rounds").child(tid).child(rid).updateChildValues(values,
                                                                          withCompletionBlock: { (error, _) in
            completion(self.getAuthError(error: error))
        })
    }

    //registers a contestant in the database
    private func registerContestant(tid: String, cid: String, contestant: Movie,
                                    completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let values = ["name": contestant.title, "image": contestant.image]
        reference.child("contestants").child(tid).child(cid).updateChildValues(values,
                                                                               withCompletionBlock: { (error, _) in
            completion(self.getAuthError(error: error))
        })
    }
}

// MARK: - Utilities

extension FirebaseTournament {
    //Generate id based on date and random int
    private func generateId() -> String {
        let rand = Int.random(in: 1000 ..< 9000)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMddhmmssSSSS"
        let now = dateformatter.string(from: Date())
        return "\(now)\(rand)"
    }

    //return date + X days
    private func getEndDate(duration: Int, start: Date) -> String? {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: duration, to: start)

        if let result = date {
            return result.dateToString()
        } else {
            return nil
        }
    }

    //return powered result (ex pow(2,4) = 16)
    private func pow(base: Int, power: Int) -> Int {
        var answer: Int = 1
        for _ in 0...power { answer *= base }
        return answer
    }

    //return number of rounds based on contestant number
    private func getNumberOfRounds(contestants: Int) -> Int {
        for index in 2 ... contestants {
            let power = pow(base: 2, power: index)
            if power == contestants {
                return index
            }
        }
        return 2
    }

    //return localized string for given error
    private func getAuthError(error: Error?) -> String? {
        guard let error = error else {
            return nil
        }
        guard let authError = AuthErrorCode(rawValue: error._code) else {
            return nil
        }
        return LocalizedString(key: authError.errorMessage).val
    }
}
