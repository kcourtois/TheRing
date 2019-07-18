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
                    completion(Tournament(title: title, description: description, contestants: [],
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
    static func getTournamentFull(tid: String, completion: @escaping (Tournament?) -> Void) {
        let reference = Database.database().reference()
        reference.child("tournaments").child(tid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let title = value?["title"] as? String,
                let description = value?["description"] as? String,
                let startTime = value?["startTime"] as? String,
                let creator = value?["creator"] as? String {
                if let date = stringToDate(str: startTime) {
                    completion(Tournament(title: title, description: description, contestants: [],
                                          startTime: date, roundDuration: 0, creator: creator))
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        })
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

            //create matches
            let sequence = stride(from: 0, to: tournament.contestants.count-2, by: 2)

            for index in sequence {
                let mid = generateId()
                let ids = ["tid": tid, "rid": rids[0], "mid": mid, "cid1": cids[index], "cid2": cids[index+1]]
                registerMatch(ids: ids, completion: { (error) in
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

    static private func registerMatch(ids: [String: String], completion: @escaping (String?) -> Void) {
        guard let tid = ids["tid"], let rid = ids["rid"], let mid = ids["mid"],
            let cid1 = ids["cid1"], let cid2 = ids["cid2"] else {
            completion(TRStrings.errorOccured.localizedString)
            return
        }
        let reference = Database.database().reference()
        let values = ["contestant1": cid1, "contestant2": cid2]
        reference.child("matches/\(tid)/\(rid)/\(mid)").updateChildValues(values, withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

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