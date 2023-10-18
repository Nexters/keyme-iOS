//
//  DailyTestListView.swift
//  Features
//
//  Created by 김영인 on 2023/09/06.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import ComposableArchitecture

import Core
import Domain
import Network
import DSKit
import Util

struct DailyTestListView: View {
    typealias DailyTestStore = ViewStore<DailyTestListFeature.State, DailyTestListFeature.Action>
    
    // Properties
    var store: StoreOf<DailyTestListFeature>
    let onItemTapped: (QuestionsStatisticsData) -> Void
    
    // Initializer
    init(store: StoreOf<DailyTestListFeature>, onItemTapped: @escaping (QuestionsStatisticsData) -> Void) {
        self.store = store
        self.onItemTapped = onItemTapped
    }
    
    // Constants
    private let horizontalPadding: CGFloat = 16
    private let topSpacerHeight: CGFloat = 75
    private let bottomSpacerHeight: CGFloat = 100
    
    // Body
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                Spacer().frame(height: topSpacerHeight)
                
                content(for: viewStore)
                
                Spacer().frame(height: bottomSpacerHeight)
            }
            .scrollIndicators(.never)
            .padding(.horizontal, horizontalPadding)
            .refreshable {
                viewStore.send(.fetchDailyStatistics)
            }
            .padding(.vertical, 1)
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
            .animation(Animation.customInteractiveSpring(), value: viewStore.dailyStatistics)
        }
    }
    
    private func content(for viewStore: DailyTestStore) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            welcomeText()
            
            if let dailyStatistics = viewStore.dailyStatistics {
                dailyUserStatistics(dailyStatistics: dailyStatistics)
                dailyTestList(
                    nickname: viewStore.nickname,
                    dailyStatistics: dailyStatistics
                ) { questionStat in
                    guard dailyStatistics.solvedCount != 0 else {
                        return
                    }
                    
                    HapticManager.shared.boong()
                    self.onItemTapped(questionStat)
                }
            } else {
                loadingView()
            }
        }
    }
    
    // MARK: - Helper Views
    private func welcomeText() -> some View {
        Text.keyme("친구들의\n답변이 쌓이고 있어요!", font: .heading1)
            .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func dailyUserStatistics(dailyStatistics: StatisticsData) -> some View {
        HStack(spacing: 4) {
            Image(uiImage: DSKitAsset.Image.person.image)
                .resizable()
                .frame(width: 16, height: 16)
            
            if dailyStatistics.solvedCount == 0 {
                Text.keyme("아직 아무도 풀지 않았어요", font: .body4)
                    .foregroundColor(.white)
            } else {
                Text.keyme("\(dailyStatistics.solvedCount)명의 친구가 문제를 풀었어요", font: .body4)
                    .foregroundColor(.white)
            }
        }
    }
    
    private func dailyTestList(
        nickname: String,
        dailyStatistics: StatisticsData,
        onItemTapped: @escaping (QuestionsStatisticsData) -> Void
    ) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(dailyStatistics.questionsStatistics) { questionsStat in
                VStack(alignment: .leading, spacing: 7.5) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().foregroundColor(Color.hex(questionsStat.category.color))
                            KFImageManager.shared.toImage(url: questionsStat.category.iconUrl)
                                .scaledToFit()
                                .frame(width: 20)
                        }
                        .frame(width: 40, height: 40)
                        
                        Text.keyme("\(nickname)님은 \(questionsStat.title)", font: .body3Semibold)
                            .lineHeight(140, forFont: .body3Semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .truncationMode(.tail)
                            .foregroundColor(.white)       
                    }
                    
                    HStack(spacing: 12) {
                        Spacer().frame(width: 40)
                        statisticsScoreText(score: questionsStat.avgScore)
                    }
                }
                .padding(20)
                .background {
                    Rectangle().foregroundColor(.white.opacity(0.05)).cornerRadius(14)
                }
                .onTapGesture {
                    onItemTapped(questionsStat)
                }
            }
        }
    }
    
    private func loadingView() -> some View {
        let mockData = StatisticsData.mockData(questionCount: 7)
        return Group {
            dailyUserStatistics(dailyStatistics: mockData)
            
            dailyTestList(
                nickname: "NICKNAME",
                dailyStatistics: mockData,
                onItemTapped: { _ in }
            )
        }
        .redacted(reason: .placeholder)
    }
    
    private func statisticsScoreText(score: Double?) -> some View {
        let text: String
        
        if let score = score {
            let formattedScore = String(format: "%.1lf", score)
            text = "평균점수 | \(formattedScore)점"
        } else {
            text = "아직 아무도 풀지 않았어요"
        }
        
        return Text.keyme(text, font: .body4)
            .foregroundColor(.white.opacity(0.5))
    }
}
