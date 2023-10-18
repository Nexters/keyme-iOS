//
//  Personality.swift
//  Domain
//
//  Created by Young Bin on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct Personality: Equatable, Identifiable {
    public let id = UUID()
    public let name: String
    public let keyword: String
    public let averageScore: Float
    
    public init(name: String, keyword: String, averageScore: Float) {
        self.name = name
        self.keyword = keyword
        self.averageScore = averageScore
    }
}
