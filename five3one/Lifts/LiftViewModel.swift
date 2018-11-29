//
//  LiftViewModel.swift
//  five3one
//
//  Created by Cody Dillon on 10/17/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LiftViewModel {
    let name: String
    let displayName: String
    let oneRepMax = BehaviorRelay<Int>(value: 0)
    
    let trainingMaxViewModel = TrainingMaxViewModel()
    
    init(lift: Lift) {
        self.name = lift.name
        self.displayName = lift.displayName
    }
}
