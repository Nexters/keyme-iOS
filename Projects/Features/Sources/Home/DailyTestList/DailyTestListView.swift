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
import DSKit
import Util

struct DailyTestListView: View {
    typealias DailyTestStore = ViewStore<DailyTestListFeature.State,
                                           DailyTestListFeature.Action>
    var store: StoreOf<DailyTestListFeature>
    let onItemTapped: (TestsStatisticsModel) -> Void
    
    init(
        store: StoreOf<DailyTestListFeature>,
        onItemTapped: @escaping (TestsStatisticsModel) -> Void
    ) {
        self.store = store
        self.onItemTapped = onItemTapped
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                welcomeText(nickname: viewStore.testData.nickname)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(uiImage: DSKitAsset.Image.person.image)
                        .resizable()
                        .frame(width: 16, height: 16)
                    
                    Text.keyme(
                        "\(viewStore.dailyStatistics.solvedCount)명의 친구가 문제를 풀었어요",
                        font: .body4
                    )
                    .foregroundColor(.white)
                }
                
                dailyTestList(viewStore)
                
                Spacer()
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onDisappear {
                viewStore.send(.onDisappear)
            }
            .padding(.horizontal, 16)
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
    
    func dailyTestList(_ viewStore: DailyTestStore) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(viewStore.dailyStatistics.testsStatistics, id: \.self) { testStatistics in
                // 메인 텍스트
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 12) {
                        // 아이콘
                        ZStack {
                            Circle()
                                .foregroundColor(testStatistics.keymeTests.icon.color)
                            
                            KFImageManager.shared.toImage(url: testStatistics.keymeTests.icon.imageURL)
                                .scaledToFit()
                                .frame(width: 20)
                        }
                        .frame(width: 40, height: 40)
                        
                        // 메인 텍스트
                        Text.keyme(
                            "\(viewStore.testData.nickname)님은 \(testStatistics.keymeTests.title)",
                            font: .body3Semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .truncationMode(.tail)
                        .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 12) {
                        Spacer().frame(width: 40)
                        statisticsScoreText(score: testStatistics.avarageScore)
                    }
                }
                .padding(20)
                .background {
                    Rectangle()
                        .foregroundColor(.white.opacity(0.05))
                        .cornerRadius(14)
                }
                .onTapGesture {
                    onItemTapped(testStatistics)
                }
            }
        }
    }
}

extension DailyTestListView {
    func statisticsScoreText(score: Double?) -> some View {
        let text: String

        if var score {
            let formattedScore = String(format: "%.1lf", score)
            text = "평균점수 | \(formattedScore)점"
        } else {
            text = "아직 아무도 풀지 않았어요"
        }
        
        return Text.keyme(text, font: .body4)
            .foregroundColor(.white.opacity(0.5))
    }
}
