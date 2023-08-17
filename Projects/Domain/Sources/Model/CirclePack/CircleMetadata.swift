//
//  CircleMetadata.swift
//  Domain
//
//  Created by Young Bin on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Foundation

public struct CircleMetadata {
    public let animationId: Int
    public let icon: Image
    public let keyword: String
    public let averageScore: Float
    public let myScore: Float
    
    public init(
        animationId: Int = Int.random(in: 0...99999),
        icon: Image,
        keyword: String,
        averageScore: Float,
        myScore: Float
    ) {
        self.animationId = animationId
        self.icon = icon
        self.keyword = keyword
        self.averageScore = averageScore
        self.myScore = myScore
    }
    
    public static var emptyData: CircleMetadata {
        return  CircleMetadata(animationId: -1, icon: Image(""), keyword: "", averageScore: 0.0, myScore: 0.0)
    }
}
