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
    public let score: Float
    
    public init(icon: Image, keyword: String, score: Float) {
        self.icon = icon
        self.keyword = keyword
        self.score = score
    }
    
    public static var emptyData: CircleMetadata {
        return  CircleMetadata(icon: Image(""), keyword: "", score: 0.0)
    }
}
