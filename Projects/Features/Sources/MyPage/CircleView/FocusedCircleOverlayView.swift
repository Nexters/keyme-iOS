//
//  FocusedCircleOverlayView.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/08/06.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Core
import DSKit
import Domain
import SwiftUI

final class FocusedCircleOverlayViewAction {
    var onDismiss: () -> Void
    var onDragChanged: (DragGesture.Value) -> Void
    var onDragEnded: (DragGesture.Value) -> Void
    
    init(
        onDismiss: @escaping () -> Void = {},
        onDragChanged: @escaping (DragGesture.Value) -> Void = { _ in },
        onDragEnded: @escaping (DragGesture.Value) -> Void = { _ in }
    ) {
        self.onDismiss = onDismiss
        self.onDragChanged = onDragChanged
        self.onDragEnded = onDragEnded
    }
}

final class FocusedCircleOverlayViewOption {
    var showTopBar: Bool
    var backgroundColor: Color
    
    init(
        showTopBar: Bool = false,
        backgroundColor: Color = DSKitAsset.Color.keymeBottom.swiftUIColor
    ) {
        self.showTopBar = showTopBar
        self.backgroundColor = backgroundColor
    }
}

struct FocusedCircleOverlayView<DetailView: View>: View {
    @Namespace private var namespace
    
    private let magnifiedCircleRatio: CGFloat = 0.9
    
    @State private var doneDragging: Bool = false
    
    @State private var currentSheet: SheetPosition = .middle
    @State private var currentSheetOffset: CGFloat = 0
    @State private var idealSheetHeight: CGFloat = 400
    
    private let focusedCircle: CircleData
    private var action: FocusedCircleOverlayViewAction
    private var option: FocusedCircleOverlayViewOption

    private let maxShrinkageDistance: CGFloat
    var detailViewBuilder: () -> DetailView
    
    internal init(
        focusedCircle: CircleData,
        maxShrinkageDistance: CGFloat,
        option: FocusedCircleOverlayViewOption = .init(),
        action: FocusedCircleOverlayViewAction = .init(),
        @ViewBuilder detailViewBuilder: @escaping () -> DetailView
    ) {
        self.focusedCircle = focusedCircle
        self.action = action
        self.option = option

        self.maxShrinkageDistance = maxShrinkageDistance
        self.detailViewBuilder = detailViewBuilder
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if option.showTopBar {
                topBar
                    .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
                    .padding(.horizontal, 17)
            }
            
            FocusedCircleView(
                namespace: namespace,
                shrinkageDistance: currentSheetOffset,
                maxShrinkageDistance: maxShrinkageDistance,
                outboundLength: UIScreen.main.bounds.width * magnifiedCircleRatio,
                blinkCircle: false,
                circleData: focusedCircle)
            .onDragChanged(self.onDragChanged)
            .onDragEnded(self.onDragEnded)
            .padding(.top, 20)

            VStack {
                BottomSheetWrapperView {
                    detailViewBuilder()
                }
                .onDragChanged(self.onDragChanged)
                .onDragEnded(self.onDragEnded)
            }
            .frame(
                minWidth: UIScreen.main.bounds.width,
                maxWidth: UIScreen.main.bounds.width,
                idealHeight: idealSheetHeight)
            .cornerRadius(16, corners: [.topLeft, .topRight])
        }
        .frame(width: UIScreen.main.bounds.width)
        .background(option.backgroundColor)
        .ignoresSafeArea(edges: [.bottom])
        .animation(
            customInteractiveSpringAnimation,
            value: doneDragging)
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
    
    var customInteractiveSpringAnimation: Animation {
        .timingCurve(0.175, 0.885, 0.32, 1.05, duration: 0.5)
    }
}

extension FocusedCircleOverlayView {
    var topBar: some View {
        ZStack(alignment: .center) {
            Text("내 성격 더 보기")
                .font(.Keyme.body3Semibold)
            
            HStack {
                Spacer()
                
                Button(action: action.onDismiss) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .scaledToFit()
                }
            }
        }
    }
}

private extension FocusedCircleOverlayView {
    func onDragChanged(_ value: DragGesture.Value) {
        doneDragging = false
        currentSheetOffset =
            currentSheet.position + value.translation.height.between(
                min: -maxShrinkageDistance,
                max: maxShrinkageDistance)
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
        
        if case .dismiss = currentSheet { action.onDismiss() }
    }
}

extension FocusedCircleOverlayView {
    func showTopBar(_ show: Bool) -> FocusedCircleOverlayView {
        self.option.showTopBar = show
        return self
    }
    
    func backgroundColor(_ color: Color) -> FocusedCircleOverlayView {
        self.option.backgroundColor = color
        return self
    }
    
    func onDismiss(_ action: @escaping () -> Void) -> FocusedCircleOverlayView {
        self.action.onDismiss = action
        return self
    }
}
