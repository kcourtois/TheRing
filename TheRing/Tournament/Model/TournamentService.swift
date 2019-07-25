//
//  TournamentService.swift
//  TheRing
//
//  Created by Kévin Courtois on 10/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
import FirebaseDatabase

class TournamentService {
    //create a tournament with given parameters
    static func createTournament(tournament: Tournament, completion: @escaping (String?) -> Void) {
        let tid = generateId()
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

    //returns a list of tournaments created by current user
    static func getUserTournaments(completion: @escaping ([Tournament]) -> Void) {
        var tournaments = [Tournament]()
        let reference = Database.database().reference()
        let preferences = Preferences()
        let group = DispatchGroup()
        group.enter()
        reference.child("user_tournaments").child(preferences.user.uid).observeSingleEvent(of: .value,
                                                                                           with: { (snapshot) in
            for case let data as DataSnapshot in snapshot.children {
                group.enter()
                if let tid = data.value as? String {
                    getTournament(tid: tid, completion: { (tournament) in
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

    //returns tournament data from tid (without rounds and matches)
    static func getTournament(tid: String, completion: @escaping (Tournament?) -> Void) {
        let reference = Database.database().reference()
        reference.child("tournaments").child(tid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let title = value?["title"] as? String,
                let description = value?["description"] as? String,
                let startTime = value?["startTime"] as? String,
                let creator = value?["creator"] as? String {
                if let date = stringToDate(str: startTime) {
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
    static func getTournamentFull(tid: String, completion: @escaping (TournamentData?) -> Void) {
        getTournament(tid: tid) { (tournament) in
            if let tournament = tournament {
                getContestants(tid: tid, completion: { (contestants) in
                    getRounds(tid: tid, completion: { (rounds) in
                        FirebaseService.getUserInfo(uid: tournament.creator, completion: { (user) in
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
    static func getRounds(tid: String, completion: @escaping ([Round]) -> Void) {
        let reference = Database.database().reference()
        var rounds = [Round]()
        let group = DispatchGroup()
        group.enter()
        reference.child("rounds").child(tid).observeSingleEvent(of: .value, with: { (snapshot) in
            for case let data as DataSnapshot in snapshot.children {
                let value = data.value as? NSDictionary
                if let endDate = value?["endDate"] as? String {
                    if let end = stringToDate(str: endDate) {
                        rounds.append(Round(rid: data.key, endDate: end))
                    }
                }
            }
            group.leave()
        })
        group.notify(queue: .main) {
            completion(rounds.sorted(by: { $0.endDate.compare($1.endDate) == .orderedAscending}))
        }
    }

    //returns contestant data
    static func getContestant(tid: String, cid: String, completion: @escaping (Contestant?) -> Void) {
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
    //returns rounds for a tournament
    static func getContestants(tid: String, completion: @escaping ([Contestant]) -> Void) {
        let reference = Database.database().reference()
        var contestants = [Contestant]()
        let group = DispatchGroup()
        group.enter()
        reference.child("contestants").child(tid).observeSingleEvent(of: .value, with: { (snapshot) in
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
    //return current round index
    static func getCurrentRoundIndex(rounds: [Round]) -> Int {
        for (index, round) in rounds.enumerated() {
            if Date() < round.endDate {
                return index
            }
        }
        return rounds.count-1
    }

    static private func registerUserTournament(tid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let preferences = Preferences()
        let values = [tid: tid]
        reference.child("user_tournaments").child(preferences.user.uid).updateChildValues(values,
                                                                          withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

    //register tournament informations
    static private func registerTournament(tid: String, values: [String: String], tournament: Tournament,
                                           completion: @escaping (String?) -> Void) {
        //create tournament
        let reference = Database.database().reference()
        reference.child("tournaments").child(tid).updateChildValues(values, withCompletionBlock: { (error, _) in
            if let error = error {
                completion(FirebaseAuthService.getAuthError(error: error))
                return
            }

            var cids = [String]()
            //create contestants
            for contestant in tournament.contestants {
                let cid = generateId()
                cids.append(cid)
                registerContestant(tid: tid, cid: cid, contestant: contestant, completion: { (error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                })
            }

            //create rounds
            let roundQt = getNumberOfRounds(contestants: tournament.contestants.count)
            var rids = [String]()
            for index in 1...roundQt {
                let rid = generateId()
                rids.append(rid)
                guard let endDate = getEndDate(duration: tournament.roundDuration*index,
                                               start: tournament.startTime) else {
                                                completion(TRStrings.errorOccured.localizedString)
                                                return
                }
                registerRound(tid: tid, rid: rid, endDate: endDate, completion: { (error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                })
            }

            registerUserTournament(tid: tid) { error in
                if let error = error {
                    completion(error)
                    return
                }
            }
        })
    }

    static private func registerRound(tid: String, rid: String, endDate: String,
                                      completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let values = ["endDate": endDate]
        reference.child("rounds").child(tid).child(rid).updateChildValues(values,
                                                                               withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

    static private func registerContestant(tid: String, cid: String, contestant: Movie,
                                           completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let values = ["name": contestant.title, "image": contestant.image]
        reference.child("contestants").child(tid).child(cid).updateChildValues(values,
                                                                               withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }
}

// MARK: - Votes

extension TournamentService {
    static func registerVote(rid: String, uid: String, cid: String,
                             completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let values = [uid: uid]
        reference.child("votes").child(rid).child(cid).updateChildValues(values,
                                                                         withCompletionBlock: { (error, _) in
                                                                            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

    //returns vote for given user and round if exists
    static func getUserVote(uid: String, rid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("votes").child(rid).observeSingleEvent(of: .value, with: { (snapshot) in
            for case let data as DataSnapshot in snapshot.children {
                let value = data.value as? NSDictionary
                if (value?[uid] as? String) != nil {
                    completion(data.key)
                }
            }
            completion(nil)
        })
    }

    //returns vote for given user and round if exists
    static func getVotes(cid: String, rid: String, completion: @escaping (UInt?) -> Void) {
        let reference = Database.database().reference()
        reference.child("votes").child(rid).child(cid).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.childrenCount)
        })
        completion(nil)
    }

    static func removeUserVote(uid: String, rid: String, cid: String) {
        let reference = Database.database().reference()
        reference.child("votes").child(rid).child(cid).child(uid).removeValue()
    }
}

// MARK: - Comments

extension TournamentService {
    static func registerComment(tid: String, user: TRUser, comment: String,
                             completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let values = [uid: uid]
        reference.child("comments").child(tid).child(uid).updateChildValues(values,
                                                                         withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

    //returns vote for given user and round if exists
    static func getUserVote(uid: String, rid: String, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        reference.child("votes").child(rid).observeSingleEvent(of: .value, with: { (snapshot) in
            for case let data as DataSnapshot in snapshot.children {
                let value = data.value as? NSDictionary
                if (value?[uid] as? String) != nil {
                    completion(data.key)
                }
            }
            completion(nil)
        })
    }

    //returns vote for given user and round if exists
    static func getVotes(cid: String, rid: String, completion: @escaping (UInt?) -> Void) {
        let reference = Database.database().reference()
        reference.child("votes").child(rid).child(cid).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.childrenCount)
        })
        completion(nil)
    }

    static func removeUserVote(uid: String, rid: String, cid: String) {
        let reference = Database.database().reference()
        reference.child("votes").child(rid).child(cid).child(uid).removeValue()
    }
}

// MARK: - Utilities

extension TournamentService {
    //Generate id based on date and random int
    static private func generateId() -> String {
        let rand = Int.random(in: 1000 ..< 9000)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMddhmmssSSSS"
        let now = dateformatter.string(from: Date())
        return "\(now)\(rand)"
    }

    //return date + X days
    static private func getEndDate(duration: Int, start: Date) -> String? {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: duration, to: start)

        if let result = date {
            return dateToString(date: result)
        } else {
            return nil
        }
    }

    static private func dateToString(date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return dateFormatter.string(from: date)
    }

    static private func stringToDate(str: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return dateFormatter.date(from: str)
    }

    //return powered result (ex pow(2,4) = 16)
    static private func pow(base: Int, power: Int) -> Int {
        var answer: Int = 1
        for _ in 0...power { answer *= base }
        return answer
    }

    //return number of rounds based on contestant number
    static private func getNumberOfRounds(contestants: Int) -> Int {
        for index in 2 ... contestants {
            let power = pow(base: 2, power: index)
            if power == contestants {
                return index
            }
        }
        return 2
    }
}

//matches/tid/rid/mid - c1, c2
//comment/tid/idc - uid, username, comment
