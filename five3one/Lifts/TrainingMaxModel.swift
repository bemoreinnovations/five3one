//
//  OneRepMaxModel.swift
//  five3one
//
//  Created by Cody Dillon on 10/19/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import Foundation

class TrainingMaxModel {
    
    private static let DefaultTrainingMaxPercent: Double = 0.9
    
    var oneRepMax: Int = 0
    var trainingMaxPercent: Double
    
    init(oneRepMax: Int = 0, trainingMaxPercent: Double = DefaultTrainingMaxPercent) {
        self.oneRepMax = oneRepMax
        self.trainingMaxPercent = trainingMaxPercent
    }
}
