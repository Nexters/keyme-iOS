//
//  ScoreListFeature.swift
//  Features
//
//  Created by Young Bin on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Domain
import Network

struct ScoreListFeature: Reducer {
    @Dependency(\.keymeAPIManager) private var network
    
    public struct State: Equatable {
        var canFetch = true
        var totalCount: Int?
        var scores: [CharacterScore]
        
        public init(totalCount: Int? = nil, scores: [CharacterScore] = []) {
            self.scores = []
        }
    }
    
    public enum Action: Equatable {
        case loadScores(ownerId: Int, questionId: Int, limit: Int)
        case saveScores(totalCount: Int, scores: [CharacterScore])
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .loadScores(ownerId, questionId, limit):
                state.canFetch = false

                return .run { send in
                    let questionScores = try await network.request(
                        .question(
                            .scores(ownerId: ownerId, questionId: questionId, limit: limit)
                        ),
                        object: QuestionResultScoresDTO.self
                    ).toCharacterScores()
                    
                    await send(.saveScores(
                        totalCount: questionScores.count,
                        scores: questionScores))
                }
                
            case let .saveScores(totalCount, data):
                state.totalCount = totalCount
                state.scores.append(contentsOf: data)
                
                state.canFetch = true
            }
            return .none
        }
    }
}
