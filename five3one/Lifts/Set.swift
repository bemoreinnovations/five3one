//
//  Set.swift
//  five3one
//
//  Created by Cody Dillon on 10/18/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import Foundation

class Set {
    var reps: Int
    
    init(reps: Int) {
        self.reps = reps
    }
}

class Five3OneSet: Set {
    
    private static let Weeks = 4
    private static let Sets = 3
    
    let week: Int
    let set: Int
    
    init(week: Int, set: Int) {
        self.week = week
        self.set = set
        super.init(reps: 5)
        
        self.reps = self.getReps(for: week, set: set)
    }
    
    var percent: Double {
        get {
            return self.getPercent(for: self.week, set: self.set)
        }
    }
    
    public func getWorkingWeight(for trainingMax: Int) -> Int {
        return Int(self.percent * Double(trainingMax))
    }
    
    static func five3OneSets() -> [[Five3OneSet]] {
        var sets: [[Five3OneSet]] = []
        for week in 1...Weeks {
            var weeklySets: [Five3OneSet] = []
            for setNumber in 1...Sets {
                let set = Five3OneSet(week: week, set: setNumber)
                weeklySets.append(set)
            }
            
            sets.append(weeklySets)
        }
        
        return sets
    }
    
    static func five3OneSets(week: Int) -> [Five3OneSet] {
        var sets = self.five3OneSets()
        return sets[week]
    }
    
    static func weekOneSets() -> [Five3OneSet] {
        return self.five3OneSets(week: 1)
    }
    
    static func weekTwoSets() -> [Five3OneSet] {
        return self.five3OneSets(week: 2)
    }
    
    static func weekThreeSets() -> [Five3OneSet] {
        return self.five3OneSets(week: 3)
    }
    
    static func weekFourSets() -> [Five3OneSet] {
        return self.five3OneSets(week: 4)
    }
    
    private func getPercent(for week: Int, set: Int) -> Double {
        switch week {
        case 1:
            return self.getWeekOnePercent(for: set)
        case 2:
            return self.getWeekTwoPercent(for: set)
        case 3:
            return self.getWeekThreePercent(for: set)
        case 4:
            return self.getWeekFourPercent(for: set)
        default:
            return self.getWeekOnePercent(for: set)
        }
    }
    
    private func getWeekOnePercent(for set: Int) -> Double {
        switch set {
        case 1:
            return 0.65
        case 2:
            return 0.75
        case 3:
            return 0.85
        default:
            return 0.65
        }
    }
    
    private func getWeekTwoPercent(for set: Int) -> Double {
        switch set {
        case 1:
            return 0.7
        case 2:
            return 0.8
        case 3:
            return 0.9
        default:
            return 0.7
        }
    }
    
    private func getWeekThreePercent(for set: Int) -> Double {
        switch set {
        case 1:
            return 0.75
        case 2:
            return 0.85
        case 3:
            return 0.95
        default:
            return 0.75
        }
    }
    
    private func getWeekFourPercent(for set: Int) -> Double {
        switch set {
        case 1:
            return 0.4
        case 2:
            return 0.5
        case 3:
            return 0.6
        default:
            return 0.6
        }
    }
    
    private func getReps(for week: Int, set: Int) -> Int {
        switch week {
        case 1:
            return self.getWeekOneReps(for: set)
        case 2:
            return self.getWeekTwoReps(for: set)
        case 3:
            return self.getWeekThreeReps(for: set)
        case 4:
            return self.getWeekFourReps(for: set)
        default:
            return self.getWeekOneReps(for: set)
        }
    }
    
    private func getWeekOneReps(for set: Int) -> Int {
        switch set {
        case 1:
            return 5
        case 2:
            return 5
        case 3:
            return 5
        default:
            return 5
        }
    }
    
    private func getWeekTwoReps(for set: Int) -> Int {
        switch set {
        case 1:
            return 3
        case 2:
            return 3
        case 3:
            return 3
        default:
            return 3
        }
    }
    
    private func getWeekThreeReps(for set: Int) -> Int {
        switch set {
        case 1:
            return 5
        case 2:
            return 3
        case 3:
            return 1
        default:
            return 5
        }
    }
    
    private func getWeekFourReps(for set: Int) -> Int {
        switch set {
        case 1:
            return 5
        case 2:
            return 5
        case 3:
            return 5
        default:
            return 5
        }
    }
}

class CompletedSet: Five3OneSet {
    var repsCompleted: Int
    var weightCompleted: Int
    
    init(set: Five3OneSet, repsCompleted: Int, weightCompleted: Int) {
        self.repsCompleted = repsCompleted
        self.weightCompleted = weightCompleted
        super.init(week: set.week, set: set.set)
    }
}
