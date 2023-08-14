//
//  FocusedCircleOverlayView.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/08/06.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Domain
import SwiftUI

struct FocusedCircleOverlayView<DetailView: View>: View {
    private let namespace: Namespace.ID
    private let focusedCircle: CircleData

    @State private var doneDragging: Bool = false
    @State private var currentSheet: SheetPosition = .middle
    @State private var currentSheetOffset: CGFloat = 0
    @State private var idealSheetHeight: CGFloat = 400
    
    @State private var showSheet = false

    private let maxShrinkageDistance: CGFloat
    private let onDismiss: () -> Bool
    
    var option: CirclePackViewOption<DetailView>
    var detailViewBuilder: (CircleData) -> DetailView
    
    internal init(
        namespace: Namespace.ID,
        focusedCircle: CircleData,
        maxShrinkageDistance: CGFloat,
        onDismiss: @escaping () -> Bool,
        option: CirclePackViewOption<DetailView>,
        @ViewBuilder detailViewBuilder: @escaping (CircleData) -> DetailView
    ) {
        self.namespace = namespace
        self.focusedCircle = focusedCircle
        self.maxShrinkageDistance = maxShrinkageDistance
        self.onDismiss = onDismiss
        self.option = option
        self.detailViewBuilder = detailViewBuilder
    }
    
    var body: some View {
        Color.black.opacity(0.01)
            .onTapGesture {
                guard onDismiss() else { return }
                showSheet = false
            }
            .onAppear {
                showSheet = true
            }
        
        VStack(alignment: .center) {
            FocusedCircleView(
                namespace: namespace,
                shrinkageDistance: currentSheetOffset,
                maxShrinkageDistance: maxShrinkageDistance,
                outboundLength: UIScreen.main.bounds.width * option.magnifiedCircleRatio,
                blinkCircle: false,
                circleData: focusedCircle)
            .padding(.top, 20)

            if showSheet {
                BottomSheetWrapperView {
                    detailViewBuilder(focusedCircle)
                }
                .onDragChanged { value in
                    doneDragging = false
                    currentSheetOffset =
                    currentSheet.position + value.translation.height.between(
                        min: -maxShrinkageDistance,
                        max: maxShrinkageDistance)
                }
                .onDragEnded { value in
                    let velocity = CGSize(
                        width:  value.predictedEndLocation.x - value.location.x,
                        height: value.predictedEndLocation.y - value.location.y
                    ).height
                    
                    let velocityThreshold: CGFloat = 200
                    switch velocity {
                    case _ where velocity > velocityThreshold:
                        currentSheet = currentSheet.previous()
                    case _ where velocity < -velocityThreshold:
                        currentSheet = currentSheet.next()
                    default:
                        break
                    }
                    
                    currentSheetOffset = currentSheet.position
                    doneDragging = true
                    
                    if case .dismiss = currentSheet {
                        guard onDismiss() else { return }
                        showSheet = false
                    }
                }
                .transition(.move(edge: .bottom))
                .frame(
                    minWidth: UIScreen.main.bounds.width,
                    maxWidth: UIScreen.main.bounds.width,
                    idealHeight: idealSheetHeight)
                .cornerRadius(16, corners: [.topLeft, .topRight])
            }
        }
        .ignoresSafeArea(edges: [.bottom])
        .animation(
            doneDragging
            ? .spring()
            : .none,
            value: doneDragging)
        .animation(.easeInOut(duration: 1), value: showSheet)
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
