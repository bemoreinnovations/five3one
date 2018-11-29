//
//  OneRepMaxViewModel.swift
//  five3one
//
//  Created by Cody Dillon on 10/19/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct TrainingMaxViewModel {
    var model: TrainingMaxModel
    
    var value = BehaviorRelay<String>(value: "")
    
    init(model: TrainingMaxModel = TrainingMaxModel()) {
        self.model = model
    }
    
    func calculateTrainingMax() -> Int {
        let oneRepMax = Int(value.value) ?? 0
        let trainingMax = Int(Double(oneRepMax) * 0.9)
        
        self.model.oneRepMax = oneRepMax
        
        return trainingMax
    }
}
