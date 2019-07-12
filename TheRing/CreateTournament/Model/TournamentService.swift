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
    //register tournament informations
    static func registerTournament(tournament: Tournament, completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let tid = generateId()
        guard let startTime = getEndDate(duration: 0, start: tournament.startTime) else {
            completion(TRStrings.errorOccured.localizedString)
            return
        }

        let values = ["title": tournament.title, "description": tournament.description,
                      "startTime": startTime]

        //create tournament
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
                print(index)
                print(index+1)
                print(cids)
                let mid = generateId()
                let ids = ["tid": tid, "rid": rids[0], "mid": mid, "cid1": cids[index], "cid2": cids[index+1]]
                registerMatch(ids: ids, completion: { (error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                })
            }
        })
    }

    static func registerRound(tid: String, rid: String, endDate: String,
                              completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let values = ["endDate": endDate]
        reference.child("rounds").child(tid).child(rid).updateChildValues(values,
                                                                               withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

    static func registerContestant(tid: String, cid: String, contestant: Movie,
                                   completion: @escaping (String?) -> Void) {
        let reference = Database.database().reference()
        let values = ["name": contestant.title, "image": contestant.image]
        reference.child("contestants").child(tid).child(cid).updateChildValues(values,
                                                                               withCompletionBlock: { (error, _) in
            completion(FirebaseAuthService.getAuthError(error: error))
        })
    }

    static func registerMatch(ids: [String: String], completion: @escaping (String?) -> Void) {
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"

        if let result = date {
            return dateFormatter.string(from: result)
        } else {
            return nil
        }
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
