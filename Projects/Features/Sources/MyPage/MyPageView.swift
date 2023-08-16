//
//  MyPageView.swift
//  Features
//
//  Created by Young Bin on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Domain
import SwiftUI

struct MyPageView: View {
    private let store: StoreOf<MyPageFeature>
    private let scoreListStore: StoreOf<ScoreListFeature>
    
    init(store: StoreOf<MyPageFeature>) {
        self.store = store
        self.scoreListStore = Store(initialState: ScoreListFeature.State(), reducer: {
            ScoreListFeature()
        })
        
        store.send(.loadCircle)
        scoreListStore.send(.loadScores)
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .topLeading) {
                CirclePackView(
                    data: viewStore.state.circleDataList,
                    detailViewBuilder: { data in
                        ScoreListView(
                            nickname: "ninkname",
                            keyword: data.metadata.keyword,
                            store: scoreListStore) // TODO: Change nickname
                    })
                .graphBackgroundColor(.hex("232323"))
                .activateCircleBlink(viewStore.state.shownFirstTime)
                .onCircleTapped { _ in
                    viewStore.send(.circleTapped)
                }
                .onCircleDismissed { _ in
                    withAnimation {
                        viewStore.send(.markViewAsShown)
                        viewStore.send(.circleDismissed)
                    }
                }

                if !viewStore.state.circleShown {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Spacer()
                            Text.keyme("마이", font: .body3Semibold)
                            Image(systemName: "info.circle")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .scaledToFit()
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        Text.keyme("친구들이 생각하는\nnickname님의 성격은?", font: .heading1) // TODO: Change nickname
                            .padding(17)
                            .transition(.opacity)
                    }
                    .foregroundColor(.white)
                }
            }
            
        }
    }
}
