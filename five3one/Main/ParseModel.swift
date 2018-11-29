//
//  ParseModel.swift
//  five3one
//
//  Created by Cody Dillon on 10/20/18.
//  Copyright © 2018 Be More Innovations. All rights reserved.
//

import Foundation
import Parse

class ParseModel: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return String(describing: type(of: self))
    }
}
