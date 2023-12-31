//
//  PinchZoomViewModifier.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/07/26.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import SwiftUI

public extension View {
    /// 화면을 꼬집어서 늘였다 줄였다 해보세요
    func pinchZooming() -> some View {
        self.modifier(PinchToZoomViewModifier())
    }
    
    func pinchZooming(with scale: Binding<CGFloat>) -> some View {
        self.modifier(PinchToZoomGestureRecognizer(scale: scale))
    }
}

struct PinchToZoomViewModifier: ViewModifier {
    @State var scale: CGFloat = 1.0
    @State var anchor: UnitPoint = .zero
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = false

    func body(content: Content) -> some View {
        content
//            .scaleEffect(scale, anchor: anchor)
            .scaleEffect(scale) // Prevent glitching
            .offset(offset)
            .overlay(
                PinchZoomViewRepresentable(
                    scale: $scale,
                    anchor: $anchor,
                    offset: $offset,
                    isPinching: $isPinching)
                .opacity(0.1))
            .animation(isPinching ? .none : .spring(), value: isPinching)
    }
}

struct PinchToZoomGestureRecognizer: ViewModifier {
    @Binding var scale: CGFloat
    @State var anchor: UnitPoint = .center
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = false

    func body(content: Content) -> some View {
        content
            .offset(offset)
            .overlay(
                PinchZoomViewRepresentable(
                    scale: $scale,
                    anchor: $anchor,
                    offset: $offset,
                    isPinching: $isPinching)
                .opacity(0.1))
            .animation(isPinching ? .none : .spring(), value: isPinching)
    }
}
