//
//  CircleData.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/25.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Foundation

public struct CircleData {
    public let isEmptyCircle: Bool
    
    public let color: Color
    public let xPoint: CGFloat
    public let yPoint: CGFloat
    public let radius: CGFloat
    
    public let metadata: CircleMetadata
    
    static public func emptyCircle(radius: CGFloat) -> CircleData {
        self.init(isEmptyCircle: true, color: .clear, xPoint: 0, yPoint: 0, radius: radius, metadata: CircleMetadata.emptyData)
    }
    
    public init(
        color: Color,
        xPoint: CGFloat,
        yPoint: CGFloat,
        radius: CGFloat,
        metadata: CircleMetadata
    ) {
        self.init(
            isEmptyCircle: false, color: color, xPoint: xPoint, yPoint: yPoint, radius: radius, metadata: metadata)
    }
    
    private init(
        isEmptyCircle: Bool,
        color: Color,
        xPoint: CGFloat,
        yPoint: CGFloat,
        radius: CGFloat,
        metadata: CircleMetadata
    ) {
        self.isEmptyCircle = isEmptyCircle
        self.color = color
        self.xPoint = xPoint
        self.yPoint = yPoint
        self.radius = radius
        self.metadata = metadata
    }
}

extension CircleData: Equatable {
    public static func == (lhs: CircleData, rhs: CircleData) -> Bool {
        lhs.id == rhs.id
    }
}

extension CircleData: Identifiable {
    public var id: UUID {
        metadata.id
    }
}
