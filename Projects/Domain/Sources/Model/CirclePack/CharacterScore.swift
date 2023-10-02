//
//  CharacterScore.swift
//  Features
//
//  Created by Young Bin on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Network
import Foundation

let globalDateFormatter = DateFormatter()

public struct CharacterScore: Identifiable, Equatable {
    public let id = UUID()
    public let score: Int
    public let date: Date
    
    public init(score: Int, date: String) {
        globalDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        globalDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        globalDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.score = score
        self.date = globalDateFormatter.date(from: date) ?? Date()
    }
}

public extension CharacterScore {
    static var mock: Self {
        return CharacterScore(score: 100, date: "2023-09-28T12:34:56.123456")
    }
}

public extension QuestionResultScoresDTO {
    func toCharacterScores() -> [CharacterScore] {
        return self.data.results.map { resultItem in
            CharacterScore(score: resultItem.score, date:  resultItem.createdAt)
        }
    }
}
