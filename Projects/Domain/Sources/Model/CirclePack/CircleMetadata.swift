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
    public let questionId: Int
    public let animationId: Int
    public let iconURL: URL?
    public let icon: Image?
    public let keyword: String
    public let averageScore: Float
    public let myScore: Float
    
    public init(
        questionId: Int,
        animationId: Int = Int.random(in: 0...99999),
        iconURL: URL?,
        icon: Image? = nil,
        keyword: String,
        averageScore: Float,
        myScore: Float
    ) {
        self.questionId = questionId
        self.animationId = animationId
        self.iconURL = iconURL
        self.icon = icon
        self.keyword = keyword
        self.averageScore = averageScore
        self.myScore = myScore
    }
    
    public static var emptyData: CircleMetadata {
        return  CircleMetadata(questionId: -1, animationId: -1, iconURL: URL(string: "temp"), keyword: "", averageScore: 0.0, myScore: 0.0)
    }
}
