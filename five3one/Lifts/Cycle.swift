//
//  Cycle.swift
//  five3one
//
//  Created by Cody Dillon on 10/20/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import Foundation
import Parse

class Cycle: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "Cycle"
    }
    
    @NSManaged var user: PFUser?
    @NSManaged var startDate: NSDate?
    @NSManaged var workouts: [CycleWorkout]?
    @NSManaged var squat: NSNumber?
    @NSManaged var benchPress: NSNumber?
    @NSManaged var deadlift: NSNumber?
    @NSManaged var shoulderPress: NSNumber?
}

class CycleWorkout: PFObject, PFSubclassing {
    public static func parseClassName() -> String {
        return "Workout"
    }
    
    @NSManaged var week: NSNumber?
    @NSManaged var exerciseName: String?
    @NSManaged var date: NSDate?
    @NSManaged var sets: [WorkoutSet]?
    @NSManaged var cycle: Cycle?
}

class WorkoutSet: PFObject, PFSubclassing {
    public static func parseClassName() -> String {
        return "Set"
    }
    
    @NSManaged var number: NSNumber?
    @NSManaged var reps: NSNumber?
    @NSManaged var weight: NSNumber?
    @NSManaged var workout: CycleWorkout?
    var week: Int?
}
