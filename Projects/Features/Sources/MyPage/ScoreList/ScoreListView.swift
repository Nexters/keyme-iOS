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
    private let scoreFetchLimit = 20
    
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
                    Text.keyme("\(nickname)님의 \(keyword) 정도는?", font: .body1)
                        .foregroundColor(keymeWhite)
                    
                    Text.keyme("응답자 수 \(viewStore.state.totalCount ?? 0)명", font: .body3Regular)
                        .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor.opacity(0.6))
                    
                    Divider()
                        .overlay(keymeWhite.opacity(0.1))
                    
                    ForEach(viewStore.state.scores, id: \.id) { scoreData in
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
                            guard viewStore.hasNext else { return }
                            
                            // 무한스크롤
                            if
                                let thirdToLastItem = viewStore.state.scores.dropLast(2).last,
                                thirdToLastItem == scoreData
                            {
                                guard viewStore.canFetch else { return }
                                viewStore.send(
                                    .loadScores(
                                        ownerId: self.ownerId,
                                        questionId: self.questionId,
                                        limit: scoreFetchLimit))
                            }
                        }
                    }
                }
                .padding(.horizontal, 17)
            }
            .onAppear {
                guard viewStore.canFetch else { return }
                viewStore.send(
                    .loadScores(
                        ownerId: self.ownerId,
                        questionId: self.questionId,
                        limit: scoreFetchLimit))
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
