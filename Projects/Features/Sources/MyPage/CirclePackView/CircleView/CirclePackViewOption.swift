//
//  CirclePackViewOption.swift
//  Features
//
//  Created by Young Bin on 2023/09/11.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
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
    /// Circle pack 그래프가 확대됐을 때 그 원이 가질 화면 가로길이에 대한 비율입니다.
    var magnifiedCircleRatio: CGFloat
    /// 그런거 모르겠고 Scale로 사이즈 조정하고 싶으면 여기
    var scale: CGFloat
    /// 원 탭 가능/불가능
    var enableInteractWithCircles: Bool
    
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
        magnifiedCircleRatio =  0.9
        scale = 1
        enableInteractWithCircles = true
        self.onCircleTappedHandler = onCircleTappedHandler
        self.onCircleDismissedHandler = onCircleDismissedHandler
    }
    
    public init(
        activateCircleBlink: Bool,
        background: Color,
        outboundLength: CGFloat,
        framePadding: CGFloat,
        magnifiedCircleRatio: CGFloat,
        scale: CGFloat,
        enableInteractWithCircles: Bool,
        onCircleTappedHandler: @escaping (CircleData) -> Void = { _ in },
        onCircleDismissedHandler: @escaping (CircleData) -> Void = { _ in }
    ) {
        self.activateCircleBlink = activateCircleBlink
        self.background = background
        self.outboundLength = outboundLength
        self.framePadding = framePadding
        self.magnifiedCircleRatio = magnifiedCircleRatio
        self.scale = scale
        self.enableInteractWithCircles = enableInteractWithCircles
        self.onCircleTappedHandler = onCircleTappedHandler
        self.onCircleDismissedHandler = onCircleDismissedHandler
    }
}
