//
//  FocusedCircleView.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/08/05.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Core
import DSKit
import Domain
import Foundation

final class FocusedCircleViewOption {
    typealias LongPressGestureValue = SequenceGesture<LongPressGesture, DragGesture>.Value
    var onLongPressStarted: () -> Void
    var onLongPressEnded: () -> Void
    var onDragChanged: (DragGesture.Value) -> Void
    var onDragEnded: (DragGesture.Value) -> Void
    
    init(
        onLongPressStarted: @escaping () -> Void = { },
        onLongPressEnded: @escaping () -> Void = { },
        onDragChanged: @escaping (DragGesture.Value) -> Void = { _ in },
        onDragEnded: @escaping (DragGesture.Value) -> Void = { _ in }
    ) {
        self.onLongPressStarted = onLongPressStarted
        self.onLongPressEnded = onLongPressEnded
        self.onDragChanged = onDragChanged
        self.onDragEnded = onDragEnded
    }
}

/// 원 하나를 상세보기 할 때 나오는 뷰
struct FocusedCircleView: View {
    private let option: FocusedCircleViewOption
    
    private let namespace: Namespace.ID
    
    private let shrinkageDistance: CGFloat
    private let maxShrinkageDistance: CGFloat
    private let outboundLength: CGFloat
    private let blinkCircle: Bool
    
    let circleData: CircleData
    
    @State var animatedOpacity = 1.0
    @State private var showComponents = false
    @GestureState private var isPressed = false
    
    init(
        option: FocusedCircleViewOption = .init(),
        namespace: Namespace.ID,
        shrinkageDistance: CGFloat,
        maxShrinkageDistance: CGFloat,
        outboundLength: CGFloat,
        blinkCircle: Bool,
        circleData: CircleData
    ) {
        self.option = option
        self.namespace = namespace
        
        self.shrinkageDistance = shrinkageDistance
        self.maxShrinkageDistance = maxShrinkageDistance
        self.outboundLength = outboundLength
        self.blinkCircle = blinkCircle
        
        self.circleData = circleData
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if circleData.isEmptyCircle {
                emptyCircleView
            } else {
                // 원
                ZStack(alignment: .center) {
                    outlineCircleView
                    
                    innerCircleView(with: circleData)
                        .opacity(blinkCircle ? animatedOpacity : 1)
                        .opacity(isPressed ? 0.5 : 1)
                    
                    if isPressed {
                        overlayingCircleView
                            .frame(width: scoreToRadius(score: CGFloat(circleData.metadata.myScore)))
                            .zIndex(1)
                    }
                    
                    circleContentView
                        .frame(width: 75, height: 75)
                        .zIndex(1.5)
                }
            }
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.15)
                .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                .updating($isPressed) { value, state, _ in
                    switch value {
                    case .second(true, nil):
                        HapticManager.shared.homeButtonTouchDown()
                        state = true
                    default:
                        break
                    }
                }
                .onEnded { _ in
                    HapticManager.shared.homeButtonTouchUp()
                    option.onLongPressEnded()
                }
                .simultaneously(
                    with: DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            guard !isPressed else { return }
                            option.onDragChanged(value)
                        }
                        .onEnded { value in
                            guard !isPressed else { return }
                            option.onDragEnded(value)
                        }))
        .frame(
            width: calculatedOutlineCircleRaduis,
            height: calculatedOutlineCircleRaduis)
        .animation(Animation.customInteractiveSpring(), value: showComponents)
        .animation(Animation.customInteractiveSpring(), value: isPressed)
        .onChange(of: isPressed, perform: { newValue in
            if newValue == true {
                option.onLongPressStarted()
            }
        })
        .onAppear {
            startAnimation()
        }
    }
}

extension FocusedCircleView: GeometryAnimatableCircle {
    var id: String {
        circleData.id.uuidString
    }
    
    func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.4)) {
                animatedOpacity = 0.3
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.animatedOpacity = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeIn(duration: 0.1)) {
                        self.animatedOpacity = 0.3
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            self.animatedOpacity = 1
                        }
                    }
                }
            }
        }
    }
    
    var emptyCircleView: some View {
        // 데이터 안 줬으면 그냥 기본 원(반창고 모양) 그리기
        ZStack {
            Circle()
                .fill(DSKitAsset.Color.keymeWhite.swiftUIColor.opacity(0.3))
                .overlay {
                    Circle().stroke(DSKitAsset.Color.keymeWhite.swiftUIColor.opacity(0.3), lineWidth: 2)
                }
                .frame(width: calculatedInnerCircleRaduis(with: CircleData.emptyCircle(radius: 0.9)))
            
            Circle()
                .fill(DSKitAsset.Color.keymeWhite.swiftUIColor.opacity(0.3))
                .overlay {
                    Circle().stroke(DSKitAsset.Color.keymeWhite.swiftUIColor.opacity(0.3), lineWidth: 2)
                }
                .frame(width: calculatedInnerCircleRaduis(
                    with: CircleData.emptyCircle(radius: 0.9 * 0.6)))
        }
    }
    
    func innerCircleView(with data: CircleData) -> some View {
        Circle()
            .fill(data.color)
            .matchedGeometryEffect(
                id: innerCircleEffectID,
                in: namespace,
                anchor: .center)
            .frame(
                width: calculatedInnerCircleRaduis(with: data),
                height: calculatedInnerCircleRaduis(with: data))
            .offset(x: 0, y: 0)
    }
    
    var outlineCircleView: some View {
        Circle()
            .fill(Color.white.opacity(0.3))
            .overlay {
                Circle()
                    .stroke(lineWidth: 1)
                    .foregroundColor(.white.opacity(0.3))
            }
            .matchedGeometryEffect(
                id: outlineEffectID,
                in: namespace,
                anchor: .center)
    }
    
    var overlayingCircleView: some View {
        Circle()
            .fill(Color.black.opacity(0.5))
            .overlay {
                Circle()
                    .stroke(lineWidth: 1)
                    .foregroundColor(.black.opacity(0.5))
            }
            .transition(.scale.combined(with: .opacity))
    }
    
    var circleContentView: some View {
        CircleContentView(
            namespace: namespace,
            metadata: circleData.metadata,
            showSubText: false,
            imageSize: 48)
            .matchedGeometryEffect(
                id: contentEffectID,
                in: namespace,
                anchor: .center)
    }
    
    var innerCircleEffectID: String {
        id + "innerCircle"
    }
    
    var outlineEffectID: String {
        id + "outline"
    }
    
    func calculatedInnerCircleRaduis(with data: CircleData) -> CGFloat {
        calculatedCircleRaduis(
            initialValue: scoreToRadius(score: CGFloat(data.metadata.averageScore)),
            targetValue: 120)
    }
    
    var calculatedOutlineCircleRaduis: CGFloat {
        calculatedCircleRaduis(
            initialValue: 320,
            targetValue: 120)
    }
    
    func calculatedCircleRaduis(
        initialValue: CGFloat,
        targetValue: CGFloat,
        step: CGFloat = 0.01
    ) -> CGFloat {
        max(
            initialValue
            + (initialValue - targetValue)
            * (shrinkageDistance / maxShrinkageDistance)
            , 0)
    }
    
    func scoreToRadius(score: CGFloat) -> CGFloat {
        return (score - 1) / (5 - 1) * (320 - 100) + 100
    }
}

extension FocusedCircleView {
    typealias LongPressGestureValue = SequenceGesture<LongPressGesture, DragGesture>.Value
    
    func onDragChanged(_ action: @escaping (DragGesture.Value) -> Void) -> FocusedCircleView {
        option.onDragChanged = action
        return self
    }
    
    func onDragEnded(_ action: @escaping (DragGesture.Value) -> Void) -> FocusedCircleView {
        option.onDragEnded = action
        return self
    }
    
    func onLongPressStarted(_ action: @escaping () -> Void) -> FocusedCircleView {
        option.onLongPressStarted = action
        return self
    }
    
    func onLongPressEnded(_ action: @escaping () -> Void) -> FocusedCircleView {
        option.onLongPressEnded = action
        return self
    }
}
