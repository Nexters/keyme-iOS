//
//  MyPageView+.swift
//  Features
//
//  Created by 이영빈 on 2023/09/08.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import DSKit
import SwiftUI

public struct ImageExportOverlayFeature: Reducer {
    public struct State: Equatable {
        let title: String
        let nickname: String
    }
    
    public enum Action: Equatable {
        case dismissImageExportMode
        case captureImage
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { _, _ in
            return .none
        }
    }
}

extension MyPageView {
    struct ImageExportOverlayView: View {
        @Binding var rotationAngle: Angle
        
        private typealias Action = () -> Void
        private let store: StoreOf<ImageExportOverlayFeature>
        
        init(store: StoreOf<ImageExportOverlayFeature>, angle: Binding<Angle>) {
            self.store = store
            self._rotationAngle = angle
        }
        
        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack(spacing: 0) {
                    HStack {
                        closeButton(action: { viewStore.send(.dismissImageExportMode) })
                        
                        Spacer()
                        
                        photoCaptureButton(action: { viewStore.send(.captureImage) })
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
                    
                    DSKitAsset.Color.keymeBlack.swiftUIColor
                        .reverseMask { maskingShape(isFilled: true).padding(32) }
                        .overlay {
                            maskingShape(isFilled: false).overlay {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text.keyme(viewStore.title, font: .body5)
                                        .foregroundColor(.white.opacity(0.3))
                                    
                                    Text.keyme("친구들이 생각하는\n\(viewStore.nickname)님의 성격은?", font: .heading1)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    horizontalSpacer
                                }
                                .padding(20)
                            }
                            .padding(32)
                        }
                        .allowsHitTesting(false)
                    
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                        Slider(value: $rotationAngle.degrees, in: -Double.pi...Double.pi, step: 0.01)
                            .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
                    }
                    .padding(20)
                    .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
                }
            }
        }
        
        private func maskingShape(isFilled: Bool) -> some View {
            let shape = RoundedRectangle(cornerRadius: 24)

            return Group {
                if isFilled {
                    shape.fill(Color.black)
                } else {
                    shape.stroke(.white.opacity(0.3))
                }
            }
        }
        
        private var horizontalSpacer: some View {
            HStack { Spacer() }
        }
        
        private func closeButton(action: @escaping Action) -> some View {
            Button(action: action) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            }
        }
        
        private func photoCaptureButton(action: @escaping Action) -> some View {
            Button(action: action) {
                HStack {
                    DSKitAsset.Image.photoExport.swiftUIImage
                    Text("이미지 저장")
                }
            }
            .foregroundColor(.white)
            .padding(3)
            .overlay { Capsule().stroke(Color.white.opacity(0.3)) }
        }
    }
}
