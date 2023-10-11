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

public struct ScoreListFeature: Reducer {
    @Dependency(\.keymeAPIManager) private var network
    
    public struct State: Equatable {
        var activeNetworkCallCount = 0
        
        var hasNext = true
        var nowFetching: Bool {
            activeNetworkCallCount != 0
        }
        var totalCount: Int?
        var questionText: String?
        var scores: [CharacterScore]
        
        public init(totalCount: Int? = nil, scores: [CharacterScore] = []) {
            self.scores = []
        }
    }
    
    public enum Action: Equatable {
        case loadQuestionInformation(ownerId: Int, questionId: Int)
        case saveQuestionInformation(text: String)
        case loadScores(ownerId: Int, questionId: Int, limit: Int)
        case saveScores(totalCount: Int, scores: [CharacterScore], hasNext: Bool)
        case clear
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadQuestionInformation(let ownerId, let questionId):
                state.activeNetworkCallCount += 1
                
                return .run { send in
                    let response = try await network.request(
                        .question(.statistics(ownerId: ownerId, questionId: questionId)),
                        object: QuestionStatisticsDTO.self
                    ).data
                    
                    await send(.saveQuestionInformation(text: response.title))
                }
                
            case .saveQuestionInformation(let questionText):
                state.questionText = questionText
                state.activeNetworkCallCount -= 1
                
            case let .loadScores(ownerId, questionId, limit):
                state.activeNetworkCallCount += 1

                return .run { send in
                    let response = try await network.request(
                        .question(
                            .scores(ownerId: ownerId, questionId: questionId, limit: limit)
                        ),
                        object: QuestionResultScoresDTO.self
                    )
                    
                    let questionScores = response.toCharacterScores()
                    await send(.saveScores(
                        totalCount: questionScores.count,
                        scores: questionScores,
                        hasNext: response.data.hasNext))
                }
                
            case let .saveScores(totalCount, data, hasNext):
                state.totalCount = totalCount
                state.scores.append(contentsOf: data)
                state.hasNext = hasNext
                state.activeNetworkCallCount -= 1
                
            case .clear:
                state = .init()
            }
        
            return .none
        }
    }
}
