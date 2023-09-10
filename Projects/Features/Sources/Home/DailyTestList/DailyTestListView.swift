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
import DSKit
import Util

struct DailyTestListView: View {
    var store: StoreOf<DailyTestListFeature>
    typealias DailyTestStore = ViewStore<DailyTestListFeature.State,
                                           DailyTestListFeature.Action>
    
    init(store: StoreOf<DailyTestListFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: 75)
                
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
            .fullFrame()
            .padding([.leading, .trailing], 16)
        }
    }
}

extension DailyTestListView {
    func welcomeText(nickname: String) -> some View {
        Text.keyme(
            "\(nickname)님 친구들의\n답변이 쌓이고 있어요!",
            font: .heading1)
        .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func dailyTestList(_ viewStore: DailyTestStore) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(viewStore.dailyStatistics.testsStatistics, id: \.self) { testStatistics in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.white.opacity(0.05))
                        .frame(height: 86)
                        .cornerRadius(14)
                    
                    HStack(spacing: 12) {
                        Spacer()
                            .frame(width: 14)
                        
                        ZStack {
                            Circle()
                                .foregroundColor(testStatistics.keymeTests.icon.color)
                            
                            KFImageManager.shared.toImage(url: testStatistics.keymeTests.icon.imageURL)
                                .scaledToFit()
                                .frame(width: 20)
                        }
                        .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading, spacing: 7) {
                            Text.keyme("\(viewStore.testData.nickname)님의 \(testStatistics.keymeTests.keyword)정도는?",
                                       font: .body3Semibold)
                                .foregroundColor(.white)
                            
                            Text.keyme("평균점수 | \(testStatistics.avarageScore)점",
                                       font: .body4)
                            .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
            }
        }
    }
}
