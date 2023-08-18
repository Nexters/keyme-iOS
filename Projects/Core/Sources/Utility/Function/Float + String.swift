//
//  Float + String.swift
//  Core
//
//  Created by Young Bin on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public extension Float {
    func toString(floatingPoint: Int = 1) -> String {
        String(format: "%.\(floatingPoint)f", self)
    }
}
