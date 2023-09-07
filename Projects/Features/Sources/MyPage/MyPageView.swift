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
    }
    
    public var body: some View {
        WithViewStore(store, observe: \.view, send: MyPageFeature.Action.view) { viewStore in
            ZStack(alignment: .topLeading) {
                CirclePackView(
                    namespace: namespace,
                    data: viewStore.shownCircleDatalist,
                    detailViewBuilder: { data in
                        let scoreListStore = store.scope(
                            state: \.scoreListState,
                            action: MyPageFeature.Action.scoreListAction)
                        
                        ScoreListView(
                            ownerId: viewStore.userId,
                            questionId: data.metadata.questionId,
                            nickname: viewStore.nickname,
                            keyword: data.metadata.keyword,
                            store: scoreListStore)
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
                .graphFrame(length: viewStore.imageExportMode ? 560 : 700)
                .ignoresSafeArea(.container)
                
                if viewStore.imageExportMode {
                    VStack(spacing: 0) {
                        HStack {
                            Button(action: { viewStore.send(.setExportPhotoMode(enabled: false)) }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Button(action: {}) {
                                HStack {
                                    DSKitAsset.Image.photoExport.swiftUIImage
                                    Text("이미지 저장")
                                }
                            }
                            .foregroundColor(.white)
                            .padding(3)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3))
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 28)
                        .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
                        
                        DSKitAsset.Color.keymeBlack.swiftUIColor
                            .allowsHitTesting(false)
                            .reverseMask {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.black)
                                    .padding(32)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(.white.opacity(0.3))
                                    .overlay {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text.keyme(
                                                viewStore.selectedSegment.title,
                                                font: .body5)
                                            .foregroundColor(.white.opacity(0.3))
                                            Text.keyme(
                                                "친구들이 생각하는\n\(viewStore.nickname)님의 성격은?",
                                                font: .heading1)
                                            .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            HStack { Spacer() }
                                        }
                                        .padding(28)
                                    }
                                    .padding(32)
                            }
                    }
                }
                
                // 개별 원이 보이거나 사진 export 모드가 아닌 경우에만 보여주는 부분
                // 탑 바, 탭 바, top5, bottom5 등
                if !viewStore.circleShown && !viewStore.imageExportMode {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Button(action: { viewStore.send(.setExportPhotoMode(enabled: true)) }) {
                                DSKitAsset.Image.photoExport.swiftUIImage
                                    .resizable()
                                    .frame(width: 35, height: 35)
                            }
                            
                            Spacer()
                            
                            Text.keyme("마이", font: .body3Semibold)
                            Image(systemName: "info.circle")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .scaledToFit()
                            
                            Spacer()
                            
                            Button(action: { viewStore.send(.prepareSettingView) }) {
                                DSKitAsset.Image.setting.swiftUIImage
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 24)
                        
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
                        
                        Text.keyme("친구들이 생각하는\n\(viewStore.nickname)님의 성격은?", font: .heading1)
                            .padding(17)
                            .transition(.opacity)
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbar(viewStore.imageExportMode ? .hidden : .visible, for: .tabBar)
            .navigationDestination(
                store: store.scope(state: \.$settingViewState, action: MyPageFeature.Action.setting),
                destination: { SettingView(store: $0) })
        }
        .onAppear {
            store.send(.requestCircle(.top5))
            store.send(.requestCircle(.low5))
            
            store.send(.view(.selectSegement(.similar)))
        }
    }
}

extension View {
    @inlinable func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask(
            ZStack(alignment: .center) {
                Rectangle()
                
                mask()
                    .blendMode(.destinationOut)
            }
                .compositingGroup()
        )
    }
}
