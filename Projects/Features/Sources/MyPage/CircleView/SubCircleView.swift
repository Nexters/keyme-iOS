//
//  CirclePackSubView.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/08/05.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Domain
import DSKit
import Foundation

/// 마이페이지 들어가자 마자 나오는 CirclePack 그래프를 이루는 원을 만들 때 쓰는 뷰
struct SubCircleView: View {
    private let namespace: Namespace.ID
    
    private let outboundLength: CGFloat
    let circleData: CircleData
    
    private let onTapGesture: () -> Void
    
    // outboundLength는 총 그래프 크기
    // circleData.radius는 총 그래프 크기에 대한 반지름 비율
    // circleData.xPoint, yPoint는 그래프 크기에 대한 좌표를 -1 ~ +1 사이로 나타낸 것
    init(
        namespace: Namespace.ID,
        outboundLength: CGFloat,
        circleData: CircleData,
        onTapGesture: @escaping () -> Void
    ) {
        self.namespace = namespace
        
        self.outboundLength = outboundLength
        self.circleData = circleData
        
        self.onTapGesture = onTapGesture
    }
    
    var body: some View {
        ZStack {
            ZStack {
                designedCircleShape
                
                circleContentView
                    .frame(width: 75, height: 75)
                    .zIndex(1)
            }
            .frame(
                width: circleData.radius * outboundLength,
                height: circleData.radius * outboundLength)
            .offset(
                x: circleData.xPoint * outboundLength / 2,
                y: -circleData.yPoint * outboundLength / 2)
            
            .onTapGesture(perform: onTapGesture)
        }
    }
}

extension SubCircleView: GeometryAnimatableCircle {
    var id: String {
        circleData.id.uuidString
    }
    
    var designedCircleShape: some View {
        Circle()
            .fill(circleData.color)
            .overlay {
                // 아웃라인 이펙트를 위한 안보이는 원
                Circle()
                    .fill(.clear)
                    .matchedGeometryEffect(
                        id: outlineEffectID,
                        in: namespace,
                        anchor: .center)
            }
            .matchedGeometryEffect(
                id: innerCircleEffectID,
                in: namespace,
                anchor: .center)
    }
    
    var circleContentView: some View {
        CircleContentView(namespace: namespace, metadata: circleData.metadata)
            .matchedGeometryEffect(
                id: contentEffectID,
                in: namespace,
                anchor: .center)
    }
}
