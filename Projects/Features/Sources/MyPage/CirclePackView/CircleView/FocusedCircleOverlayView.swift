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

struct FocusedCircleDetailView<DetailView: View>: View {
    @Namespace var namespace
    @State var isPersonalityCirclePressed = false
    @State private var currentSheet: SheetPosition = .middle
    @State private var currentSheetOffset: CGFloat = 0
    @State private var doneDragging = true

    let maxSheetOffset: CGFloat = 200
    let idealSheetHeight: CGFloat = 400
    
    let focusedCircleData: CircleData
    let detailViewBuilder: (CircleData) -> DetailView
    
    init(
        focusedCircle: CircleData,
        detailViewBuilder: @escaping (CircleData) -> DetailView,
        onDragChanged: @escaping (DragGesture.Value) -> Void = { _ in },
        onDragEnded: @escaping (DragGesture.Value) -> Void = { _ in }
    ) {
        self.focusedCircleData = focusedCircle
        self.detailViewBuilder = detailViewBuilder
    }

    var body: some View {
        VStack {
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
                outboundLength: UIScreen.main.bounds.width * 0.9,
                blinkCircle: false,
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
        .animation(
            Animation.customInteractiveSpring(),
            value: isPersonalityCirclePressed)
        .animation(
            Animation.customInteractiveSpring(),
            value: focusedCircleData)
        .animation(
            Animation.customInteractiveSpring(),
            value: doneDragging)
        .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
    }
}

private extension FocusedCircleDetailView {
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
