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
    
    private let store: StoreOf<MyPageFeature>
    private let exportModeScale = 0.7
    private let imageSaver = ImageSaver()
    
    @State private var tempImage: ScreenImage?
    @State private var screenshotFired: Bool = false

    @State var graphScale: CGFloat = 1
    @State var graphRotationAngle: Angle = .radians(0.018)
    
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
                case true:
                    ProgressView()
                    
                case false:
                    if viewStore.shownCircleDatalist.isEmpty {
                        topBar(viewStore, showExportImageButton: false)
                            .padding(.top, 10)
                            .padding(.horizontal, 24)
                        
                        emptyCircleView(shareButtonAction: {
                            viewStore.send(.requestTestURL)
                        })
                        
                    } else {
                        // Content에 있는 뷰를 캡처하는 래퍼 뷰
                        Screenshotter(
                            isTakingScreenshot: $screenshotFired,
                            content: {
                                circlePackGraphView(viewStore).ignoresSafeArea(.container, edges: .bottom)
                            },
                            onScreenshotTaken: {
                                saveScreenShotWith(
                                    graphImage: $0,
                                    title: viewStore.selectedSegment.title,
                                    nickname: viewStore.nickname)
                            })
                        
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
                            ImageExportOverlayView(
                                store: $0,
                                angle: $graphRotationAngle,
                                captureAction: {
                                    screenshotFired = true
                                    viewStore.send(.captureImage)
                                },
                                dismissAction: {
                                    graphScale /= exportModeScale
                                }
                            )
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
            .redacted(reason: viewStore.nowFetching ? .placeholder : [])
        }
        .sheet(item: $tempImage, content: { image in
            // FIXME: 디자인 나오기 전 임시
            ZStack {
                DSKitAsset.Color.keymeBlack.swiftUIColor
                Image(uiImage: image.image)
                    .resizable()
                    .scaledToFit()
                    .fullFrame()
                
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            let image = image.image

                            if let storiesUrl = URL(string: "instagram-stories://share?source_application=969563760790586") {
                                if UIApplication.shared.canOpenURL(storiesUrl) {
                                    guard let imageData = image.pngData() else { return }
                                    let pasteboardItems: [String: Any] = [
                                        "com.instagram.sharedSticker.stickerImage": imageData,
                                        "com.instagram.sharedSticker.backgroundTopColor": "#171717",
                                        "com.instagram.sharedSticker.backgroundBottomColor": "#171717"
                                    ]
                                    let pasteboardOptions = [
                                        UIPasteboard.OptionsKey.expirationDate:
                                            Date().addingTimeInterval(300)
                                    ]
                                    UIPasteboard.general.setItems([pasteboardItems], options:
                                                                    pasteboardOptions)
                                    UIApplication.shared.open(storiesUrl, options: [:],
                                                              completionHandler: nil)
                                } else {
                                    print("Sorry the application is not installed")
                                }
                            }
                            
                            
                        }) {
                            Text("스토리")
                        }
                        
                        Button(action: { imageSaver.save(image.image) { error in
                            // TODO: Show alert
                        } }) {
                            Text("앨범에 저장하기")
                        }
                        
                        ShareLink(item: Image(uiImage: image.image), preview: SharePreview("Keyme - 나의 성격", image: Image(uiImage: image.image)))
                    }
                }
            }
        })
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

// MARK: - Subviews
private extension MyPageView {
    func circlePackGraphView(
        _ viewStore: ViewStore<MyPageFeature.State.View, MyPageFeature.Action.View>
    ) -> some View {
        CirclePackView(
            namespace: namespace,
            data: viewStore.shownCircleDatalist,
            scale: $graphScale,
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
            Button(action: {
                viewStore.send(.enableImageExportMode)
                graphScale *= exportModeScale
            }) {
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

// MARK: - Tools
private extension MyPageView {
    struct ScreenImage: Identifiable {
        let id = UUID()
        let image: UIImage
    }

    @MainActor func saveScreenShotWith(graphImage image: UIImage?, title: String, nickname: String) {
        guard let image else {
            // TODO: Show alert
            return
        }

        let exportView = MyPageImageExportView(title: title, nickname: nickname) {
            ZStack {
                DSKitAsset.Color.keymeBlack.swiftUIColor
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.0 / 0.81)
            }
        }
        .frame(width: 310, height: 570) // Image size

        let renderer = ImageRenderer(content: exportView)
        renderer.scale = displayScale
        
        guard let exportImage = renderer.uiImage else {
            // TODO: Show alert
            return
        }
        
        // Show bottom sheets
        tempImage = ScreenImage(image: exportImage)
    }
}
