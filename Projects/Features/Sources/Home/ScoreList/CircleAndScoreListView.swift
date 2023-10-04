//
//  CircleAndScoreListView.swift
//  Features
//
//  Created by 이영빈 on 9/25/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Core
import ComposableArchitecture
import Domain
import DSKit
import Network

public struct CircleAndScoreListFeature: Reducer {
    @Dependency(\.keymeAPIManager) var network
    
    public struct State: Equatable {
        var scoreListState: ScoreListFeature.State
        
        var circleData: CircleData
        var nickname: String {
            @Dependency(\.commonVariable) var commonVariable
            return commonVariable.nickname
        }
        
        init(circleData: CircleData) {
            self.scoreListState = .init()
            self.circleData = circleData
        }
    }
    
    public enum Action: Equatable {
        case saveMyScore(myScore: Int)
        
        case scoreListAction(ScoreListFeature.Action)
        
        case view(View)
        
        public enum View {
            case updateMyScore
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.scoreListState, action: /Action.scoreListAction) {
            ScoreListFeature()
        }
        
        Reduce { state, action in
            switch action {
                // MARK: - Internal actions
            case .saveMyScore(let myScore):
                state.circleData = state.circleData.withUpdatedMyScore(Float(myScore))
                return .none
                
            case .scoreListAction:
                return .none
                
                // MARK: - View actions
            case .view(.updateMyScore):
                let circleData = state.circleData
                let metadata = circleData.metadata
                
                return .run { send in
                    async let questionStat = network.request(
                        .question(.statistics(
                            ownerId: metadata.ownerId,
                            questionId: metadata.questionId)
                        ),
                        object: QuestionStatisticsDTO.self).data
                            
                    await send(.saveMyScore(myScore: try questionStat.myScore))
                } catch: { error, _ in
                    // TODO: Show alert
                    print("@@", error)
                }
            }
        }
    }
}

struct CircleAndScoreListView: View {
    private let store: StoreOf<CircleAndScoreListFeature>

    init(store: StoreOf<CircleAndScoreListFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }, send: CircleAndScoreListFeature.Action.view) { viewStore in
            FocusedCircleDetailView(focusedCircle: viewStore.circleData) { circleData -> ScoreListView in
                let metaData = circleData.metadata
                let scoreListStore = store.scope(
                    state: \.scoreListState,
                    action: CircleAndScoreListFeature.Action.scoreListAction)
                
                return ScoreListView(
                    ownerId: metaData.ownerId,
                    questionId: metaData.questionId,
                    nickname: viewStore.nickname,
                    keyword: metaData.keyword,
                    store:  scoreListStore
                )
            }
            .addCommonNavigationBar()
            .ignoresSafeArea(edges: .bottom)
            .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
            .onAppear {
                viewStore.send(.updateMyScore)
            }
        }
    }
}
