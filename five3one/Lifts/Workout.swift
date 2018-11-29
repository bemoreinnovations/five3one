//
//  Workout.swift
//  five3one
//
//  Created by Cody Dillon on 10/20/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import Foundation
import Firebase

class Workout {
    var cycle: DocumentReference?
    var date: Timestamp?
    var exercise: DocumentReference?
    var sets: [ASet]?
    
    init(cycle: DocumentReference? = nil, date: Date? = nil) {
        
    }
}

extension Workout
{
    convenience init?(dictionary: [String : Any])
    {
        self.init()
        self.cycle = dictionary["cycle"] as? DocumentReference
        self.exercise = dictionary["exercise"] as? DocumentReference
        self.date = dictionary["date"] as? Timestamp
        let array = dictionary["sets"] as? [[String: Any]]
        var sets: [ASet] = []
        array?.forEach({
            if let set = ASet(dictionary: $0) {
                sets.append(set)
            }
        })
        self.sets = sets
    }
}

class ASet {
    var set: NSNumber?
    var reps: NSNumber?
    var weight: NSNumber?
}

extension ASet
{
    convenience init?(dictionary: [String : Any])
    {
        self.init()
        self.set = dictionary["set"] as? NSNumber
        self.reps = dictionary["reps"] as? NSNumber
        self.weight = dictionary["weight"] as? NSNumber
    }
}
