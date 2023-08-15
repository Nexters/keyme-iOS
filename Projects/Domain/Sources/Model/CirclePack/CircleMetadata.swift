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
    public let id = UUID()
    public let icon: Image
    public let keyword: String
    public let averageScore: Float
    public let myScore: Float
    
    public init(icon: Image, keyword: String, averageScore: Float, myScore: Float) {
        self.icon = icon
        self.keyword = keyword
        self.averageScore = averageScore
        self.myScore = myScore
    }
    
    public static var emptyData: CircleMetadata {
        return  CircleMetadata(icon: Image(""), keyword: "", averageScore: 0.0, myScore: 0.0)
    }
}
