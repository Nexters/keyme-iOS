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
    public let isEmptyCircle: Bool
    
    public let id = UUID()
    public let color: Color
    public let xPoint: CGFloat
    public let yPoint: CGFloat
    public let radius: CGFloat
    
    static public var emptyCircle: CircleData {
        self.init()
    }
    
    private init() {
        self.isEmptyCircle = true
        self.color = .clear
        self.xPoint = 0
        self.yPoint = 0
        self.radius = 0.9
    }
    
    public init(
        color: Color,
        xPoint: CGFloat,
        yPoint: CGFloat,
        radius: CGFloat
    ) {
        self.isEmptyCircle = false
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
