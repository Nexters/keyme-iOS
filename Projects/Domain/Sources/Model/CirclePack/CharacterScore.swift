//
//  CharacterScore.swift
//  Features
//
//  Created by Young Bin on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct CharacterScore: Identifiable, Equatable {
    public let id = UUID()
    public let score: Int
    public let date: Date
    
    public init(score: Int, date: Date) {
        self.score = score
        self.date = date
    }
}
