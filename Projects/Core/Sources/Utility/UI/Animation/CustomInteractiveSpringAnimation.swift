//
//  CustomInteractiveSpringAnimation.swift
//  Core
//
//  Created by Young Bin on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public extension Animation {
    // 테스트하고프면 https://www.cssportal.com/css-cubic-bezier-generator/
    static func customInteractiveSpring(duration: CGFloat = 0.5) -> Animation {
        .timingCurve(0.175, 0.885, 0.32, 1.05, duration: duration) // default: 0.5
    }
}
