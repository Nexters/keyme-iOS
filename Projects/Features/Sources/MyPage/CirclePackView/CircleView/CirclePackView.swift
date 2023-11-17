//
//  CirclePackView.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/25.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Core
import ComposableArchitecture
import Domain
import DSKit
import Foundation

public struct CirclePackView<DetailView: View>: View {
    private let namespace: Namespace.ID
    private let lowestZIndex: CGFloat = 0
    
    @Binding private var graphScale: CGFloat
    
    // 애니메이션 관련
    @State private var doneDragging = true
    @State private var firstFetch = true
    
    @State private var currentSheet: SheetPosition = .middle
    @State private var currentSheetOffset: CGFloat = 0
    @State private var maxSheetOffset: CGFloat = 200
    @State private var idealSheetHeight: CGFloat = 400
    
    @State private var animationEnded: Bool = true
    
    @State private var showMorePersonalitySheet: Bool = false
    @State private var focusedCircleData: CircleData?
    @State private var isPersonalityCirclePressed = false
    
    private var circleData: [CircleData]
    private let option: CirclePackViewOption<DetailView>
    private let detailViewBuilder: (CircleData) -> DetailView
    
    public init(
        namespace: Namespace.ID,
        data: [CircleData],
        scale: Binding<CGFloat>,
        rotationAngle: Angle = .degrees(45),
        @ViewBuilder detailViewBuilder: @escaping (CircleData) -> DetailView
    ) {
        self.option = .init()
        self.namespace = namespace
        self.circleData = data.rotate(degree: rotationAngle)

        self.detailViewBuilder = detailViewBuilder
        
        self._graphScale = scale
    }
        
    public var body: some View {
        ZStack {
            // 백그라운드에 깔리는 배경색
            option.background
                .ignoresSafeArea()
                .zIndex(lowestZIndex)
            
            // Circle pack 메인 뷰
            mainView
                .zIndex(lowestZIndex + 1)
            
            // 아래에 깔린 뷰 블러시키는 특수 뷰
            // `opacity`를 이용해서 visibility 조절함
            BackgroundBlurringView(style: .dark)
                .ignoresSafeArea()
                .opacity(focusedCircleData == nil ? 0 : 1)
                .onTapGesture(perform: onDismiss)
                .zIndex(lowestZIndex + 2)
            
            // 개별보기
            if let focusedCircleData {
                individualCircleView(of: focusedCircleData)
                    .frame(width: UIScreen.main.bounds.width)
                    .ignoresSafeArea(edges: [.bottom])
                    .zIndex(lowestZIndex + 3)
            }
        }
        .animation(
            Animation.customInteractiveSpring(),
            value: isPersonalityCirclePressed)
        .animation(
            Animation.customInteractiveSpring(),
            value: graphScale)
        .animation(
            Animation.customInteractiveSpring(),
            value: focusedCircleData)
        .animation(
            Animation.customInteractiveSpring(),
            value: doneDragging)
        .onChange(of: focusedCircleData) { _ in
            animationEnded = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                self.animationEnded = true
            }
        }
    }
    
    var mainView: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            ScrollViewReader { proxy in
                ZStack(alignment: .center) {
                    Color.clear.id(0) // Center position
                    
                    ForEach(circleData) { data in
                        if data == focusedCircleData {
                            Circle().fill(.clear)
                        } else {
                            SubCircleView(
                                namespace: namespace,
                                outboundLength: option.outboundLength,
                                circleData: data,
                                onTapGesture: {
                                    guard animationEnded else { return }
                                    guard option.enableTapOnSubCircles else { return }
                                    
                                    option.onCircleTappedHandler(data)
                                    focusedCircleData = data
                                })
                        }
                    }
                }
                .onAppear {
                    guard firstFetch else { return }
                    
                    proxy.scrollTo(0) // Scroll to center on appear
                    firstFetch = false
                }
            }
            .frame(width: option.outboundLength, height: option.outboundLength)
            .scaleEffect(graphScale)
            .padding(option.framePadding)
            .pinchZooming(with: $graphScale)
        }
    }
    
    func individualCircleView(of focusedCircleData: CircleData) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Group {
                if isPersonalityCirclePressed {
                    ScoreAndPersonalityView(
                        title: "나의 점수",
                        score: focusedCircleData.metadata.myScore)
                } else {
                    ScoreAndPersonalityView(
                        circleData: focusedCircleData)
                }
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            
            FocusedCircleView(
                namespace: namespace,
                shrinkageDistance: currentSheetOffset,
                maxShrinkageDistance: maxSheetOffset,
                outboundLength: UIScreen.main.bounds.width * option.magnifiedCircleRatio,
                blinkCircle: option.activateCircleBlink,
                circleData: focusedCircleData)
            .onDragChanged(self.onDragChanged)
            .onDragEnded(self.onDragEnded)
            .onLongPressStarted {
                isPersonalityCirclePressed = true
            }
            .onLongPressEnded {
                isPersonalityCirclePressed = false
            }
            .transition(.offset(x: 1, y: 1).combined(with: .opacity))
            .padding(.vertical, 12)
            
            VStack {
                BottomSheetWrapperView {
                    detailViewBuilder(focusedCircleData)
                }
                .onDragChanged(self.onDragChanged)
                .onDragEnded(self.onDragEnded)
            }
            .frame(
                minWidth: UIScreen.main.bounds.width,
                maxWidth: UIScreen.main.bounds.width,
                idealHeight: idealSheetHeight
            )
            .cornerRadius(16, corners: [.topLeft, .topRight])
            .transition(.move(edge: .bottom))
        }
    }
}

private extension CirclePackView {
    func onDragChanged(_ value: DragGesture.Value) {
        doneDragging = false
        currentSheetOffset =
            currentSheet.position + value.translation.height.between(
                min: -maxSheetOffset,
                max: maxSheetOffset)
    }
    
    func onDragEnded(_ value: DragGesture.Value) {
        let velocity = CGSize(
            width:  value.predictedEndLocation.x - value.location.x,
            height: value.predictedEndLocation.y - value.location.y
        ).height
        
        let velocityThreshold: CGFloat = 150
        switch velocity {
        case _ where velocity > velocityThreshold:
            currentSheet = currentSheet.previous()
        case _ where velocity < -velocityThreshold:
            currentSheet = currentSheet.next()
        default:
            HapticManager.shared.unexpectedDelight()
        }
        
        currentSheetOffset = currentSheet.position
        doneDragging = true
        
        if case .dismiss = currentSheet { onDismiss() }
    }
    
    func onDismiss() {
        guard animationEnded else { return }
        
        if let focusedCircleData {
            option.onCircleDismissedHandler(focusedCircleData)
        }
        
        focusedCircleData = nil
        currentSheetOffset = 0
        currentSheet = .middle
    }
    
    enum SheetPosition: CaseIterable {
        case dismiss
        case middle
        case high
        
        var position: CGFloat {
            switch self {
            case .high:
                return -200
            case .middle:
                return 0
            case .dismiss:
                return 0
            }
        }
    }
}

extension CirclePackView {
    func activateCircleBlink(_ activated: Bool) -> CirclePackView {
        self.option.activateCircleBlink = activated
        return self
    }
    
    /// 그래프의 백그라운드 컬러를 설정함
    func graphBackgroundColor(_ color: Color) -> CirclePackView {
        self.option.background = color
        return self
    }
    
    /// 프레임의 크기를 설정합니다.
    ///
    /// 가로-세로가 동일한 정사각형이므로 한 개의 길이만 받습니다. 기본값은 350입니다.
    func graphFrame(length: CGFloat) -> CirclePackView {
        self.option.outboundLength = length
        return self
    }
    
    /// 전체 프레임과 그래프 사이 거리를 설정합니다.
    ///
    /// 기본값은 350입니다.
    func graphFramePadding(_ factor: CGFloat) -> CirclePackView {
        self.option.framePadding = factor
        return self
    }
    
    /// 버블차트의 원 크기 스케일을 잡습니다.
    ///
    /// 기본값은 당연히 1입니다.
    func graphScale(_ factor: CGFloat) -> CirclePackView {
        self.option.scale = factor
        return self
    }
    
    func enableTapOnSubCircles(_ enabled: Bool) -> CirclePackView {
        self.option.enableTapOnSubCircles = enabled
        return self
    }
    
    func onCircleTapped(_ handler: @escaping (CircleData) -> Void) -> CirclePackView {
        self.option.onCircleTappedHandler = handler
        return self
    }
    
    func onCircleDismissed(_ handler: @escaping (CircleData) -> Void) -> CirclePackView {
        self.option.onCircleDismissedHandler = handler
        return self
    }
}
