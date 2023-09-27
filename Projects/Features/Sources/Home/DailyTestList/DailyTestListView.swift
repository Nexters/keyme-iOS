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
    typealias DailyTestStore = ViewStore<DailyTestListFeature.State,
                                           DailyTestListFeature.Action>
    var store: StoreOf<DailyTestListFeature>
    let onItemTapped: (QuestionsStatisticsData) -> Void
    
    init(
        store: StoreOf<DailyTestListFeature>,
        onItemTapped: @escaping (QuestionsStatisticsData) -> Void
    ) {
        self.store = store
        self.onItemTapped = onItemTapped
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                Spacer().frame(height: 75)
                
                VStack(alignment: .leading, spacing: 20) {
                    welcomeText(nickname: viewStore.testData.nickname)
                    
                    Spacer()
                    
                    if let dailyStatistics  = viewStore.dailyStatistics {
                        HStack(spacing: 4) {
                            Image(uiImage: DSKitAsset.Image.person.image)
                                .resizable()
                                .frame(width: 16, height: 16)
                            
                            Text.keyme(
                                "\(dailyStatistics.solvedCount)명의 친구가 문제를 풀었어요",
                                font: .body4
                            )
                            .foregroundColor(.white)
                        }
                        
                        dailyTestList(
                            nickname: viewStore.testData.nickname,
                            dailyStatistics: dailyStatistics)
                    } else {
                        HStack {
                            Spacer()
                            CustomProgressView()
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)

                Spacer().frame(height: 100) // 아래 공간 띄우기
            }
            .refreshable {
                viewStore.send(.fetchDailyStatistics)
            }
            .padding(.vertical, 1) // 왜인지는 모르지만 영역 넘치는 문제를 해결해주니 놔둘 것..
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onDisappear {
                viewStore.send(.onDisappear)
            }
        }
    }
}

extension DailyTestListView {
    func welcomeText(nickname: String) -> some View {
        Text.keyme(
            "친구들의\n답변이 쌓이고 있어요!",
            font: .heading1)
        .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func dailyTestList(nickname: String, dailyStatistics: StatisticsData) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(dailyStatistics.questionsStatistics, id: \.self) { questionsStat in
                
                // 메인 텍스트
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 12) {
                        // 아이콘
                        ZStack {
                            Circle()
                                .foregroundColor(Color.hex(questionsStat.category.color))
                            
                            KFImageManager.shared.toImage(url: questionsStat.category.iconUrl)
                                .scaledToFit()
                                .frame(width: 20)
                        }
                        .frame(width: 40, height: 40)
                        
                        // 메인 텍스트
                        Text.keyme(
                            "\(nickname)님은 \(questionsStat.title)",
                            font: .body3Semibold)
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
                    Rectangle()
                        .foregroundColor(.white.opacity(0.05))
                        .cornerRadius(14)
                }
                .onTapGesture {
                    HapticManager.shared.boong()
                    onItemTapped(questionsStat)
                }
            }
        }
    }
}

extension DailyTestListView {
    func statisticsScoreText(score: Double?) -> some View {
        let text: String

        if let score {
            let formattedScore = String(format: "%.1lf", score)
            text = "평균점수 | \(formattedScore)점"
        } else {
            text = "아직 아무도 풀지 않았어요"
        }
        
        return Text.keyme(text, font: .body4)
            .foregroundColor(.white.opacity(0.5))
    }
}
