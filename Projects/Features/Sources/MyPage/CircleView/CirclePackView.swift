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

public class CirclePackViewOption<DetailView: View> {
    var activateCircleBlink: Bool
    /// Circle pack 그래프 배경색
    var background: Color
    /// Circle pack 그래프의 크기
    var outboundLength: CGFloat
    /// Circle pack 그래프의 크기에 줄 패딩값. 즉, 뷰 전체 프레임과 그래프 사이에 둘 거리.
    var framePadding: CGFloat
    var rotationAngle: Angle
    /// Circle pack 그래프가 확대됐을 때 그 원이 가질 화면 가로길이에 대한 비율입니다.
    var magnifiedCircleRatio: CGFloat
    
    var onCircleTappedHandler: (CircleData) -> Void
    var onCircleDismissedHandler: (CircleData) -> Void
    
    public init(
        onCircleTappedHandler: @escaping (CircleData) -> Void = { _ in },
        onCircleDismissedHandler: @escaping (CircleData) -> Void = { _ in }
    ) {
        activateCircleBlink = true
        background = .white
        outboundLength = 700
        framePadding = 350
        rotationAngle = .degrees(0)
        magnifiedCircleRatio =  0.9
        self.onCircleTappedHandler = onCircleTappedHandler
        self.onCircleDismissedHandler = onCircleDismissedHandler
    }
    
    public init(
        activateCircleBlink: Bool,
        background: Color,
        outboundLength: CGFloat,
        framePadding: CGFloat,
        rotationAngle: Angle,
        magnifiedCircleRatio: CGFloat,
        onCircleTappedHandler: @escaping (CircleData) -> Void = { _ in },
        onCircleDismissedHandler: @escaping (CircleData) -> Void = { _ in }
    ) {
        self.activateCircleBlink = activateCircleBlink
        self.background = background
        self.outboundLength = outboundLength
        self.framePadding = framePadding
        self.rotationAngle = rotationAngle
        self.magnifiedCircleRatio = magnifiedCircleRatio
        self.onCircleTappedHandler = onCircleTappedHandler
        self.onCircleDismissedHandler = onCircleDismissedHandler
    }
}

public struct CirclePackView<DetailView: View>: View {
    @Namespace private var namespace
    
    // 애니메이션 관련
    @State private var doneDragging = true
    
    @State private var currentSheet: SheetPosition = .middle
    @State private var currentSheetOffset: CGFloat = 0
    @State private var maxSheetOffset: CGFloat = 200
    @State private var idealSheetHeight: CGFloat = 400
    
    @State private var animationEnded: Bool = true
    
    @State private var showMorePersonalitySheet: Bool = false
    @State private var focusedCircleData: CircleData?
    @State private var isPersonalityCirclePressed = false
    
    private let circleData: [CircleData]
    private let option: CirclePackViewOption<DetailView>
    private let detailViewBuilder: (CircleData) -> DetailView
    
    private let morePersonalitystore = Store(initialState: MorePersonalityFeature.State()) {
        MorePersonalityFeature()
    }

    public init(
        data: [CircleData],
        @ViewBuilder detailViewBuilder: @escaping (CircleData) -> DetailView
    ) {
        self.circleData = data
        self.option = .init()
        
        self.morePersonalitystore.send(.loadPersonality)
        self.detailViewBuilder = detailViewBuilder
    }
        
    public var body: some View {
        ZStack {
            // 백그라운드에 깔리는 배경색
            option.background
                .ignoresSafeArea()
                .zIndex(0)
            
            // Circle pack 메인 뷰
            // 전체 스크롤, 원상복구되는 줌 들어가 있음
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ZStack {
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
                                    option.onCircleTappedHandler(data)
                                    focusedCircleData = data
                                })
                        }
                    }
                }
                .frame(width: option.outboundLength, height: option.outboundLength)
                .padding(option.framePadding)
                .rotationEffect(option.rotationAngle)
                .pinchZooming()
            }
            .zIndex(1)
            
            // 아래에 깔린 뷰 블러시키는 특수 뷰
            // `opacity`를 이용해서 visibility 조절함
            BackgroundBlurringView(style: .dark)
                .ignoresSafeArea()
                .zIndex(1.5)
                .opacity(focusedCircleData == nil ? 0 : 1)
                .onTapGesture(perform: onDismiss)
            
            // 개별보기
            VStack(alignment: .center, spacing: 0) {
                if let focusedCircleData {
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
                    .onLongPressStarted { _ in
                        isPersonalityCirclePressed = true
                    }
                    .onLongPressEnded { _ in
                        isPersonalityCirclePressed = false
                    }
                    .transition(.offset(x: 1, y: 1).combined(with: .opacity))
                    .padding(.vertical, 12)
//                    .transition(.offset(x: 1, y: 1)) // Magic line. 왠진 모르겠지만 돌아가는 중이니 건들지 말 것
                    
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
            .frame(width: UIScreen.main.bounds.width)
            .ignoresSafeArea(edges: [.bottom])
            .zIndex(2)
            
            // 성격 더보기
            morePersonalityButton
                .zIndex(2.5)
                .opacity(focusedCircleData == nil ? 1 : 0)
        }
        .animation(
            Animation.customInteractiveSpring(),
            value: isPersonalityCirclePressed)
        .animation(
            Animation.customInteractiveSpring(),
            value: focusedCircleData)
        .animation(
            Animation.customInteractiveSpring(),
            value: doneDragging)
        .onChange(of: focusedCircleData) { _ in
            animationEnded = false
            // 애니메이션 끝나는 타이밍 잡기 귀찮아서 대충 시간 계산해서 적어놨는데 나중에 들어내겠음(과연..?)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                self.animationEnded = true
            }
        }
        .fullScreenCover(isPresented: $showMorePersonalitySheet) {
            FocusedCircleOverlayView(
                focusedCircle: CircleData.emptyCircle(radius: 0.9),
                maxShrinkageDistance: maxSheetOffset,
                detailViewBuilder: {
                    MorePersonalityView(store: morePersonalitystore)
                })
            .backgroundColor(DSKitAsset.Color.keymeBlack.swiftUIColor)
            .showTopBar(true)
            .onDismiss {
                self.showMorePersonalitySheet = false
            }
        }
    }
}

private extension CirclePackView {
    /// 성격 더보기
    var morePersonalityButton: some View {
        VStack(alignment: .center) {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    showMorePersonalitySheet = true
                    print("Tapped")
                }) {
                    VStack {
                        Text.keyme("내 성격 더보기", font: .body3Semibold)
                        
                        UpArrowButton()
                            .frame(width: 24, height: 24)
                    }
                    .frame(height: 52)
                    .foregroundColor(.white)
                }
                .frame(width: 135, height: 75)
                .padding(.bottom, 18)
                .contentShape(Rectangle())
                
                Spacer()
            }
        }
        .fullFrame()
        .background(
            // 위에서 약 3/4 지점에서 시작하는 그래디언트
            LinearGradient(
                colors: [.clear, .black],
                startPoint: .init(x: 0, y: 0.7),
                endPoint: .init(x: 0, y: 1))
            .allowsHitTesting(false))
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
    
    /// 그래프를 돌려봅니다.
    ///
    /// 기본값은 0도(`Angle(degree: 0))`입니다.
    func graphRotation(angle: Angle) -> CirclePackView {
        self.option.rotationAngle = angle
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

struct CirclePackView_Previews: PreviewProvider {
    static var previews: some View {
        CirclePackView(
            data: [
                CircleData(
                    color: .blue,
                    xPoint: 0.2068919881427701,
                    yPoint: 0.7022698911578201,
                    radius: 0.14644660940672627,
                    metadata: CircleMetadata(
                        icon: Image(systemName: "person.fill"),
                        keyword: "표현력",
                        averageScore: 4.2,
                        myScore: 4.2)),
                CircleData(
                    color: .red,
                    xPoint: -0.20710678118654763,
                    yPoint: -0.4925857155047088,
                    radius: 0.20710678118654754,
                    metadata: CircleMetadata(
                        icon: Image(systemName: "person.fill"),
                        keyword: "표현력",
                        averageScore: 4.2,
                        myScore: 3.5)),
                CircleData(
                    color: .gray,
                    xPoint: -0.2218254069479773,
                    yPoint: 0.6062444788590935,
                    radius: 0.29289321881345254,
                    metadata: CircleMetadata(
                        icon: Image(systemName: "person.fill"),
                        keyword: "표현력",
                        averageScore: 4.2,
                        myScore: 3.5)),
                CircleData(
                    color: .cyan,
                    xPoint: -0.5857864376269051,
                    yPoint: 0.0,
                    radius: 0.4142135623730951,
                    metadata: CircleMetadata(
                        icon: Image(systemName: "person.fill"),
                        keyword: "표현력",
                        averageScore: 4.2,
                        myScore: 3.5)),
                CircleData(
                    color: .mint,
                    xPoint: 0.4142135623730951,
                    yPoint: 0.0,
                    radius: 0.5857864376269051,
                    metadata: CircleMetadata(
                        icon: Image(systemName: "person.fill"),
                        keyword: "표현력",
                        averageScore: 4.2,
                        myScore: 3.5))
            ],
            detailViewBuilder: { _ in
                let scores = [
                    CharacterScore(score: 4, date: Date()),
                    CharacterScore(score: 5, date: Date()),
                    CharacterScore(score: 3, date: Date()),
                    CharacterScore(score: 1, date: Date()),
                    CharacterScore(score: 2, date: Date())
                ]
                
                DetailCharacterView(title: "키미님의 애정도", subtitle: "서브타이틀", scores: scores)
            })
        .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
    }
}