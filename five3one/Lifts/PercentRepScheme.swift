//
//  PercentRepScheme.swift
//  five3one
//
//  Created by Cody Dillon on 10/18/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import Foundation

class PercentRepScheme: RepScheme {
    
    var percent: Double
    
    init(percent: Double, sets: Int, reps: Int) {
        self.percent = percent
        super.init(sets: sets, reps: reps)
    }
}
