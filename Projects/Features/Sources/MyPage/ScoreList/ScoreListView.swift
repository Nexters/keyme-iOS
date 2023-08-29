//
//  ScoreListView.swift
//  Features
//
//  Created by Young Bin on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import SwiftUI
import ComposableArchitecture
import Domain
import DSKit
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
        case loadScores(questionId: Int)
        case saveScores(totalCount: Int, scores: [CharacterScore])
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadScores(let id):
                state.canFetch = false

                return .run { send in
                    let questionScores = try await network.request(
                        .question(.scores(questionId: id)), object: QuestionResultScoresDTO.self)
                        .toCharacterScores()
                    
                    await send(.saveScores(
                        totalCount: questionScores.count,
                        scores: questionScores))
                }
                
            case .saveScores(let totalCount, let data):
                state.totalCount = totalCount
                state.scores.append(contentsOf: data)
                
                state.canFetch = true
            }
            return .none
        }
    }
}

struct ScoreListView: View {
    private let formatter: RelativeDateTimeFormatter
    
    private let questionId: Int
    private let nickname: String
    private let keyword: String
    private let store: StoreOf<ScoreListFeature>
    
    init(
        questionId: Int,
        nickname: String,
        keyword: String,
        store: StoreOf<ScoreListFeature>
    ) {
        self.formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateTimeStyle = .named
        
        self.questionId = questionId
        self.nickname = nickname
        self.keyword = keyword
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    Text.keyme("\(nickname)님의 \(keyword) 정도는?", font: .body1)
                        .foregroundColor(keymeWhite)
                    
                    Text.keyme("응답자 수 \(viewStore.state.totalCount ?? 0)명", font: .body3Regular)
                        .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor.opacity(0.6))
                    
                    Divider()
                        .overlay(keymeWhite.opacity(0.1))
                    
                    ForEach(viewStore.state.scores) { scoreData in
                        ZStack {
                            HStack {
                                Spacer()
                                Text.keyme("\(scoreData.score)점", font: .body1)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                Text.keyme(
                                    "\(formatter.localizedString(for: scoreData.date, relativeTo: Date()))",
                                    font: .caption1)
                                .foregroundColor(.white.opacity(0.3))
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56)
                        .background(keymeWhite.opacity(0.05))
                        .cornerRadius(16)
                        .onAppear {
                            if
                                let thirdToLastItem = viewStore.state.scores.dropLast(2).last,
                                thirdToLastItem == scoreData
                            {
                                guard viewStore.canFetch else { return }
                                viewStore.send(.loadScores(questionId: self.questionId))
                            }
                        }
                    }
                }
                .padding(.horizontal, 17)
            }
            .onAppear {
                guard viewStore.canFetch else { return }
                viewStore.send(.loadScores(questionId: self.questionId))
            }
        }
    }
    
    var keymeWhite: Color {
        DSKitAsset.Color.keymeWhite.swiftUIColor
    }
}

struct ScoreListView_Previews: PreviewProvider {
    static var previews: some View {
        MorePersonalityView(store: Store(initialState: MorePersonalityFeature.State(), reducer: {
            MorePersonalityFeature()
        }))
    }
}
