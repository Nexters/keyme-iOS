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
    
    @State var graphRotationAngle: Angle = .degrees(45)

    private let store: StoreOf<MyPageFeature>
    
    init(store: StoreOf<MyPageFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: \.view, send: MyPageFeature.Action.view) { viewStore in
            ZStack(alignment: .topLeading) {
                // Default bg color
                DSKitAsset.Color.keymeBlack.swiftUIColor
                    .ignoresSafeArea()
                
                CirclePackView(
                    namespace: namespace,
                    data: viewStore.shownCircleDatalist,
                    rotationAngle: graphRotationAngle,
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
                .graphScale(viewStore.imageExportMode ? 0.7 : 1)
                .ignoresSafeArea(.container, edges: .bottom)
            
                // 개별 원이 보이거나 사진 export 모드가 아닌 경우에만 보여주는 부분
                // 탑 바, 탭 바, top5, bottom5 등
                if !viewStore.circleShown && !viewStore.imageExportMode {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Button(action: { viewStore.send(.enableImageExportMode) }) {
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
                    .transition(.opacity)
                }
                
                // Export 모드에 진입합니다
                
                IfLetStore(store.scope(
                    state: \.imageExportModeState,
                    action: MyPageFeature.Action.imageExportModeAction)
                ) {
                    ImageExportOverlayView(store: $0, angle: $graphRotationAngle)
                }
                .transition(
                    .opacity.combined(with: .scale(scale: 1.5))
                        .animation(Animation.customInteractiveSpring()))
                .zIndex(ViewZIndex.high.rawValue)
            }
            .toolbar(viewStore.imageExportMode ? .hidden : .visible, for: .tabBar)
            .navigationDestination(
                store: store.scope(state: \.$settingViewState, action: MyPageFeature.Action.setting),
                destination: { SettingView(store: $0) })
            .animation(Animation.customInteractiveSpring(duration: 0.5), value: viewStore.circleShown)
            .animation(Animation.customInteractiveSpring(), value: viewStore.imageExportMode)
            .border(DSKitAsset.Color.keymeBlack.swiftUIColor, width: viewStore.imageExportMode ? 5 : 0)
        }
        .onAppear {
            store.send(.requestCircle(.top5))
            store.send(.requestCircle(.low5))
            
            store.send(.view(.selectSegement(.similar)))
        }
    }
    
    private enum ViewZIndex: CGFloat {
        case low = 0
        case high = 1
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
