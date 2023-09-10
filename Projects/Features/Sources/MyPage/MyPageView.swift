//
//  MyPageView.swift
//  Features
//
//  Created by Young Bin on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Core
import ComposableArchitecture
import Domain
import DSKit
import SwiftUI

struct MyPageView: View {
    @Namespace private var namespace
    @Environment(\.displayScale) var displayScale

    @State var graphRotationAngle: Angle = .radians(0.018)
    
    private let store: StoreOf<MyPageFeature>
    private let imageSaver = ImageSaver()
    
    init(store: StoreOf<MyPageFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: \.view, send: MyPageFeature.Action.view) { viewStore in
            ZStack(alignment: .topLeading) {
                // Default bg color
                DSKitAsset.Color.keymeBlack.swiftUIColor
                    .ignoresSafeArea()
                
                switch viewStore.nowFetching {
                case .circleData:
                    ProgressView()
                    
                case .none:
                    if viewStore.shownCircleDatalist.isEmpty {
                        topBar(viewStore, showExportImageButton: false)
                            .padding(.top, 10)
                            .padding(.horizontal, 24)
                        
                        emptyCircleView(shareButtonAction: {
                            viewStore.send(.requestTestURL)
                        })
                        
                    } else {
                        circlePackGraphView(viewStore).ignoresSafeArea(.container, edges: .bottom)
                        
                        // 개별 원이 보이거나 사진 export 모드가 아닌 경우에만 보여주는 부분
                        // 탑 바, 탭 바, top5, bottom5 등
                        if !viewStore.circleShown && !viewStore.imageExportMode {
                            VStack(alignment: .leading, spacing: 0) {
                                topBar(viewStore, showExportImageButton: true)
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
                            ImageExportOverlayView(store: $0, angle: $graphRotationAngle, captureAction: {
                                let exportTargetView = MyPageImageExportView(
                                    title: viewStore.selectedSegment.title,
                                    nickname: viewStore.nickname
                                ) {
                                    circlePackGraphView(viewStore)
                                    //                                .frame(width: 300, height: 600)
                                    //                            Image(systemName: "person").foregroundColor(.white)
                                }
                                    .frame(width: 720, height: 1280)
                                
                                let renderer = ImageRenderer(content: exportTargetView)
                                renderer.scale = displayScale
                                let image = exportTargetView.capture()
                                
                                //                        guard let image = renderer.uiImage else {
                                guard let image else {
                                    return
                                }
                                
                                imageSaver.save(image) { error in
                                    print(error)
                                }
                                
                                viewStore.send(.captureImage)
                            })
                        }
                        .transition(
                            .opacity.combined(with: .scale(scale: 1.5))
                            .animation(Animation.customInteractiveSpring()))
                        .zIndex(ViewZIndex.high.rawValue)
                    }
                }
            }
            .toolbar(viewStore.imageExportMode ? .hidden : .visible, for: .tabBar)
            .navigationDestination(
                store: store.scope(state: \.$settingViewState, action: MyPageFeature.Action.setting),
                destination: { SettingView(store: $0) })
            .alert(store: store.scope(state: \.$alertState, action: MyPageFeature.Action.alert))
            .animation(Animation.customInteractiveSpring(duration: 0.5), value: viewStore.circleShown)
            .animation(Animation.customInteractiveSpring(), value: viewStore.imageExportMode)
            .border(DSKitAsset.Color.keymeBlack.swiftUIColor, width: viewStore.imageExportMode ? 5 : 0)
        }
        .sheet(
            store: store.scope(
                state: \.$shareSheetState,
                action: MyPageFeature.Action.shareSheet)
        ) { store in
            ActivityViewController(store: store)
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

private extension MyPageView {
    func circlePackGraphView(
        _ viewStore: ViewStore<MyPageFeature.State.View, MyPageFeature.Action.View>
    ) -> some View {
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
    }
    
    func emptyCircleView(shareButtonAction: @escaping () -> Void) -> some View {
        VStack(alignment: .center) {
            Spacer()
            
            DSKitAsset.Image.mypageEmpty.swiftUIImage
                .padding(.bottom, 28)
            
            Text.keyme("아직 문제를 푼 친구가 없어요!", font: .body2)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            Text.keyme("친구들에게 내 성격을 물어볼까요?", font: .body4)
                .foregroundColor(DSKitAsset.Color.keymeMediumgray.swiftUIColor)
                .padding(.bottom, 45)
            
            // TODO: change
            Button(action: shareButtonAction) {
                HStack {
                    Spacer()
                    
                    Text.keyme("친구에게 공유하기", font: .mypage).frame(height: 60)
                    
                    Spacer()
                }
            }
            .foregroundColor(.black)
            .background(.white)
            .cornerRadius(16)
            .padding(.horizontal, 16)
            
            Spacer()
            HStack { Spacer() }
        }
    }
    
    func topBar(
        _ viewStore: ViewStore<MyPageFeature.State.View, MyPageFeature.Action.View>,
        showExportImageButton: Bool
    ) -> some View {
        HStack(spacing: 4) {
            Button(action: { viewStore.send(.enableImageExportMode) }) {
                DSKitAsset.Image.photoExport.swiftUIImage
                    .resizable()
                    .frame(width: 35, height: 35)
            }
            .opacity(showExportImageButton ? 1 : 0)
            
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
        .foregroundColor(.white)
    }
}

extension View {
    func capture() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = UIScreen.main.bounds.size
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        view?.layoutIfNeeded()  // Force layout

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { ctx in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
