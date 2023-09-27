//
//  CircleAndScoreListView.swift
//  Features
//
//  Created by 이영빈 on 9/25/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Domain
import Network

public struct CircleAndScoreListFeature: Reducer {
    @Dependency(\.keymeAPIManager) var network
    
    public struct State: Equatable {
        var scoreListState: ScoreListFeature.State?
        
        var view: View
        struct View: Equatable {
            var nickname: String {
                @Dependency(\.environmentVariable) var environmentVariable
                return environmentVariable.nickname
            }
            let circleData: CircleData
        }
        
        init(circleData: CircleData) {
            self.view = View(circleData: circleData)
        }
    }
    
    public enum Action: Equatable {
        case saveScoresList(totalCount: Int, scores: [CharacterScore])
        
        case scoreListAction(ScoreListFeature.Action)
        
        case view(View)
        
        public enum View {
            case fetchScoreList
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                // MARK: - Internal actions
            case .saveScoresList(let totalCount, let scores):
                state.scoreListState = ScoreListFeature.State(
                    totalCount: totalCount,
                    scores: scores
                )
                
                return .none
                
            case .scoreListAction:
                return .none
                
                // MARK: - View actions
            case .view(.fetchScoreList):
                let circleData = state.view.circleData
                let metadata = circleData.metadata
                
                return .run { send in
                    let response = try await network.request(
                        .question(
                            .scores(ownerId: metadata.ownerId,
                                    questionId: metadata.questionId,
                                    limit: 20)
                        ),
                        object: QuestionResultScoresDTO.self)
                    
                    let totalCount = response.data.totalCount
                    let scores = response.toCharacterScores()
                    
                    await send(.saveScoresList(totalCount: totalCount, scores: scores))
                }
            }
        }
        .ifLet(
            \.scoreListState,
             action: /Action.scoreListAction
        ) {
            ScoreListFeature()
        }
    }
}

struct CircleAndScoreListView: View {
    private let store: StoreOf<CircleAndScoreListFeature>
    
    init(store: StoreOf<CircleAndScoreListFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0.view }, send: CircleAndScoreListFeature.Action.view) { viewStore in
            FocusedCircleDetailView(focusedCircle: viewStore.circleData) { circleData in
                IfLetStore(store.scope(
                    state: \.scoreListState,
                    action: CircleAndScoreListFeature.Action.scoreListAction
                )) { scoreStore in
                    let metaData = circleData.metadata
                    
                    ScoreListView(
                        ownerId: metaData.ownerId,
                        questionId: metaData.questionId,
                        nickname: viewStore.nickname,
                        keyword: metaData.keyword,
                        store: scoreStore
                    )
                } else: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .onAppear {
                DispatchQueue.global().async {
                    viewStore.send(.fetchScoreList)
                }
            }
        }
    }
}
