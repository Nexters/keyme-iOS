//
//  MyPageView.swift
//  Features
//
//  Created by Young Bin on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Domain
import DSKit
import SwiftUI

struct MyPageView: View {
    @Namespace private var namespace
    
    private let store: StoreOf<MyPageFeature>
    
    init(store: StoreOf<MyPageFeature>) {
        self.store = store
        
        store.send(.requestCircle(.top5))
        store.send(.requestCircle(.low5))
        
        store.send(.selectSegement(.similar))
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .topLeading) {
                CirclePackView(
                    namespace: namespace,
                    data: viewStore.shownCircleDatalist,
                    detailViewBuilder: { data in
                        let scoreListStore = store.scope(
                            state: \.scoreListState,
                            action: MyPageFeature.Action.scoreListAction)
                        
                        if
                            let userId = viewStore.userId,
                            let nickname = viewStore.nickname
                        {
                            ScoreListView(
                                ownerId: userId,
                                questionId: data.metadata.questionId,
                                nickname: nickname,
                                keyword: data.metadata.keyword,
                                store: scoreListStore)
                        } else {
                            // TODO: Show alert
                        }
                    })
                .graphBackgroundColor(DSKitAsset.Color.keymeBlack.swiftUIColor)
                .activateCircleBlink(viewStore.state.shownFirstTime)
                .onCircleTapped { _ in
                    viewStore.send(.circleTapped)
                }
                .onCircleDismissed { _ in
                    withAnimation(Animation.customInteractiveSpring()) {
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
                        
                        SegmentControlView(
                            segments: MyPageSegment.allCases,
                            selected: viewStore.binding(
                                get: \.selectedSegment,
                                send: { .selectSegement($0) })
                        ) { segment in
                            Text.keyme(segment.title, font: .body3Semibold)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                        .frame(height: 50)
                        .padding(.horizontal, 17)
                        .padding(.top, 25)
                        
                        Text.keyme("친구들이 생각하는\n키미님의 성격은?", font: .heading1) // TODO: Change nickname
                            .padding(17)
                            .transition(.opacity)
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}
