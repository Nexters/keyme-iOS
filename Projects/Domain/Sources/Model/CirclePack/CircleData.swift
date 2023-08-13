//
//  CircleData.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/25.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Foundation

public struct CircleData: Identifiable {
    public let id = UUID()
    public let color: Color
    public let xPoint: CGFloat
    public let yPoint: CGFloat
    public let radius: CGFloat
    
    
    public init(
        color: Color,
        xPoint: CGFloat,
        yPoint: CGFloat,
        radius: CGFloat
    ) {
        self.color = color
        self.xPoint = xPoint
        self.yPoint = yPoint
        self.radius = radius
    }
}

extension CircleData: Equatable {
    public static func == (lhs: CircleData, rhs: CircleData) -> Bool {
        lhs.id == rhs.id
    }
}
