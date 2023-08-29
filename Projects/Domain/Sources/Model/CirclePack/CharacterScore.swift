//
//  CharacterScore.swift
//  Features
//
//  Created by Young Bin on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Network
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

public extension QuestionResultScoresDTO {
    func toCharacterScores() -> [CharacterScore] {
        return self.data.results.map { resultItem in
            CharacterScore(score: resultItem.score, date: resultItem.createdAt)
        }
    }
}
