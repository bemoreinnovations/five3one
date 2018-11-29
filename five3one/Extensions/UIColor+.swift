//
//  UIColor+.swift
//  five3one
//
//  Created by Cody Dillon on 10/17/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(rgb: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha))
    }
    
    struct AppColors {
        static let blue = UIColor(rgb: 0x4295f4)
        static let blueGrey = UIColor(rgb: 0xb7c2ce)
        static let teal = UIColor(rgb: 0x00c4a0)
    }
}
