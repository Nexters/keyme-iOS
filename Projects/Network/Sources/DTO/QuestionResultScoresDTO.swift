//
//  QuestionResultScoresDTO.swift
//  Network
//
//  Created by 이영빈 on 2023/08/29.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public struct QuestionResultScoresDTO: Decodable {
    let code: Int
    public let data: DataResponse
    let message: String
    
    public struct DataResponse: Decodable {
        public let hasNext: Bool
        public let results: [ResultItem]
        public let totalCount: Int
    }

    public struct ResultItem: Decodable {
        public let createdAt: Date
        public let id: Int
        public let score: Int
    }
}
