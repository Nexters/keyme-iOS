//
//  CirclePackSubView.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/08/05.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Domain
import Foundation

/// 마이페이지 들어가자 마자 나오는 CirclePack 그래프를 이루는 원을 만들 때 쓰는 뷰
struct SubCircleView: View {
    private let namespace: Namespace.ID
    private let id: String
    
    private let outboundLength: CGFloat
    let circleData: CircleData
    
    private let onTapGesture: () -> Void
    
    @State private var isPressed = false
    
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
        self.id = circleData.id.uuidString
        
        self.outboundLength = outboundLength
        self.circleData = circleData
        
        self.onTapGesture = onTapGesture
    }
    
    var body: some View {
        ZStack {
            ZStack {
                designedCircle
                
                contentView
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
            .animation(.spring(), value: isPressed)
        }
    }
}

extension SubCircleView: GeometryAnimatableCircle {
    var icon: Image {
        Image(systemName: "person.fill")
    }
    
    var character: String {
        "인싸력"
    }
    
    var designedCircle: some View {
        Circle()
            .fill(circleData.color)
            .overlay {
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
    
    var contentView: some View {
        VStack {
            icon
                .foregroundColor(isPressed ? .white : .black.opacity(0.4))
            Text(character)
                .foregroundColor(isPressed ? .white : .black.opacity(0.4))
                .font(.system(size: 14))
        }
        .matchedGeometryEffect(
            id: contentEffectID,
            in: namespace,
            anchor: .center)
    }
}
