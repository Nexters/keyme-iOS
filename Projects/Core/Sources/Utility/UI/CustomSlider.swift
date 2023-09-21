//
//  CustomSlider.swift
//  Core
//
//  Created by ab180 on 2023/09/21.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Foundation

public struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    public init(value: Binding<Double>, range: ClosedRange<Double>) {
        self._value = value
        self.range = range
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .foregroundColor(.hex("FB5563"))
                    .frame(height: 16)
                    .cornerRadius(20)
                
                // Thumb 오른쪽
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: geometry.size.width - thumbPosition(in: geometry), height: 16)
                    .cornerRadius(20)
                    .padding(.leading, thumbPosition(in: geometry))
                
                // Thumb
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .offset(x: thumbPosition(in: geometry))
                    .gesture(DragGesture().onChanged { gesture in
                        updateValue(from: gesture, in: geometry)
                    })
            }
        }
        .frame(height: 20)
    }
}

extension CustomSlider {
    // 엄지손가락 위치 계산하기
    private func thumbPosition(in geometry: GeometryProxy) -> CGFloat {
        let fraction = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let trackWidth = geometry.size.width - 20
        return CGFloat(fraction) * trackWidth
    }
    
    // 드래그 제스터 기반으로 값 업데이트
    private func updateValue(from gesture: DragGesture.Value, in geometry: GeometryProxy) {
        let newValue = Double(
            gesture.location.x / geometry.size.width)
            * (range.upperBound - range.lowerBound)
            + range.lowerBound
        
        value = min(max(newValue, range.lowerBound), range.upperBound)
    }
}
