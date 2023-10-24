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
    @State var isDragging = false
    
    @Binding var value: Double
    let range: ClosedRange<Double>
    let color: Color
    let needSnap: Bool
    let showLabel: Bool
    
    var label: BalloonView.Label {
        switch value {
        case ...1.5:
            return .hellNo
        case 1.5..<2.5:
            return .no
        case 2.5..<3.5:
            return .soso
        case 3.5..<4.5:
            return .yes
        case 4.5...:
            return .hellYe
        default:
            return .soso
        }
    }

    public init(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        color: Color = .hex("FB5563"),
        needSnap: Bool = false,
        showLabel: Bool = false
    ) {
        self._value = value
        self.range = range
        self.color = color
        self.showLabel = showLabel
        self.needSnap = needSnap
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .foregroundColor(color)
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
                    .overlay {
                        if showLabel {
                            BalloonView(label: self.label)
                                .offset(y: -40)
                                .animation(nil, value: UUID())
                        }
                    }
                    .offset(x: thumbPosition(in: geometry))
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            isDragging = true
                            updateValue(from: gesture, in: geometry)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                    )
            }
            .onTapGesture { point in
                // Get the tap location and update the value
                let newValue = Double(
                    point.x / geometry.size.width)
                * (range.upperBound - range.lowerBound)
                + range.lowerBound
                
                value = min(max(newValue, range.lowerBound), range.upperBound)
                if needSnap {
                    value = round(value)
                }
            }
        }
        .frame(height: 20)
        .onChange(of: isDragging) { isDragging in
            guard isDragging == false, needSnap else {
                return
            }
            
            self.value = round(value)
        }
    }
}

extension CustomSlider {
    struct BalloonView: View {
        let label: Label
        
        var body: some View {
            ZStack {
                DSKitAsset.Image.textBalloon.swiftUIImage
                    .resizable()
                    .frame(width: 110, height: 60)
                    .scaledToFit()
                
                Text.keyme(label.rawValue, font: .body4)
                    .foregroundColor(.white)
                    .padding()
                    .offset(y: -7)
            }
        }
        
        struct Triangle: Shape {
            func path(in rect: CGRect) -> Path {
                var path = Path()
                
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
                path.closeSubpath()
                
                return path
            }
        }

        // FIXME: 귀찮아서 박았다. 남자는 하드코딩
        enum Label: String {
            case hellNo = "매우 아니다"
            case no = "아니다"
            case soso = "보통이다"
            case yes = "그렇다"
            case hellYe = "매우 그렇다"
        }
    }
    
    private var currentStep: Int {
        let step = (range.upperBound - range.lowerBound) / 50
        return Int(value / step)
    }
    
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
