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

struct ScoreListView: View {
    // Constants
    private let scoreFetchLimit = 20
    
    // Properties
    private let formatter: RelativeDateTimeFormatter
    private let ownerId: Int
    private let questionId: Int
    private let nickname: String
    private let keyword: String
    private let store: StoreOf<ScoreListFeature>
    
    init(
        ownerId: Int,
        questionId: Int,
        nickname: String,
        keyword: String,
        store: StoreOf<ScoreListFeature>
    ) {
        self.formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateTimeStyle = .named
        
        self.ownerId = ownerId
        self.questionId = questionId
        self.nickname = nickname
        self.keyword = keyword
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    headerView(using: viewStore)
                        .redacted(reason: viewStore.nowFetching ? .placeholder : [])
                    
                    Divider().overlay(keymeWhite.opacity(0.1))
                    
                    if viewStore.nowFetching {
                        scoreListLoading()
                    } else {
                        scoreList(using: viewStore)
                    }
                }
                .padding(.horizontal, 17)
            }
            .onAppear { loadScores(for: viewStore) }
            .onDisappear { viewStore.send(.clear) }
            .animation(Animation.customInteractiveSpring(), value: viewStore.nowFetching)
        }
    }
    
    // MARK: - Subviews
    
    private func headerView(using viewStore: ViewStoreOf<ScoreListFeature>) -> some View {
        VStack(alignment: .leading) {
            Text.keyme("\(nickname)님의 \(keyword) 정도는?", font: .body1)
                .foregroundColor(keymeWhite)
            Text.keyme("응답자 수 \(viewStore.state.totalCount ?? 0)명", font: .body3Regular)
                .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor.opacity(0.6))
        }
    }
    
    private func scoreList(using viewStore: ViewStoreOf<ScoreListFeature>) -> some View {
        ForEach(viewStore.state.scores, id: \.id) { scoreData in
            ScoreRow(scoreData: scoreData)
                .onAppear {
                    checkForInfiniteScrolling(scoreData: scoreData, with: viewStore)
                }
        }
    }
    
    private func scoreListLoading() -> some View {
        ForEach((0..<6).map { _ in CharacterScore.mock }, id: \.id) { scoreData in
            ScoreRow(scoreData: scoreData)
                .redacted(reason: .placeholder)
        }
    }
    
    private func ScoreRow(scoreData: CharacterScore) -> some View {
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
    }
    
    // MARK: - Helpers
    
    private func loadScores(for viewStore: ViewStoreOf<ScoreListFeature>) {
        guard !viewStore.nowFetching else { return }
        viewStore.send(.loadScores(ownerId: ownerId, questionId: questionId, limit: scoreFetchLimit))
    }
    
    private func checkForInfiniteScrolling(scoreData: CharacterScore, with viewStore: ViewStoreOf<ScoreListFeature>) {
        guard viewStore.hasNext else { return }
        
        if
            let thirdToLastItem = viewStore.state.scores.dropLast(2).last,
            thirdToLastItem == scoreData,
            !viewStore.nowFetching
        {
            viewStore.send(.loadScores(ownerId: ownerId, questionId: questionId, limit: scoreFetchLimit))
        }
    }
    
    private var keymeWhite: Color {
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
