//
//  MyPageView+.swift
//  Features
//
//  Created by 이영빈 on 2023/09/08.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Core
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
        private let captureAction: () -> Void
        private let dismissAction: () -> Void
        @Binding var rotationAngle: Angle

        private typealias Action = () -> Void
        private let store: StoreOf<ImageExportOverlayFeature>
        private let imageSaver = ImageSaver()
        
        init(
            store: StoreOf<ImageExportOverlayFeature>,
            angle: Binding<Angle>,
            captureAction: @escaping () -> Void,
            dismissAction: @escaping () -> Void
        ) {
            self.store = store
            self._rotationAngle = angle
            self.captureAction = captureAction
            self.dismissAction = dismissAction
        }
        
        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack(spacing: 0) {
                    HStack {
                        closeButton(action: {
                            viewStore.send(.dismissImageExportMode)
                            dismissAction()
                        })
                        
                        Spacer()
                        
                        photoCaptureButton(action: {
                            viewStore.send(.captureImage)
                            captureAction()
                        })
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
                    
                    imageExportTargetView(
                        title: viewStore.title,
                        nickname: viewStore.nickname)
                    .allowsHitTesting(false)
                    
                    HStack {
                        Spacer()
                        
                        Knob(angle: $rotationAngle)
                            .frame(width: 100, height: 100)
                            .offset(y: 50)
                        
                        Spacer()
                    }
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
                    .resizable()
                    .frame(width: 24, height: 24)
                    .scaledToFit()
                    .foregroundColor(.white)
            }
        }
        
        private func photoCaptureButton(action: @escaping Action) -> some View {
            Button(action: action) {
                HStack {
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                    Text.keyme("이미지 저장", font: .body4)
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 7)
            .padding(.horizontal, 12)
            .overlay { Capsule().stroke(DSKitAsset.Color.keymeMediumgray.swiftUIColor) }
        }
        
        private func imageExportTargetView(title: String, nickname: String) -> some View {
            ZStack {
                DSKitAsset.Color.keymeBlack.swiftUIColor
                    .reverseMask { maskingShape(isFilled: true).padding(32) }
                
                ZStack {
                    maskingShape(isFilled: false)
                    
                    MyPageImageExportView(title: title, nickname: nickname, content: { EmptyView() })
                }
                .padding(32)
            }
        }
    }
}

public struct MyPageImageExportView<Content: View>: View {
    let title: String
    let nickname: String
    let content: Content
    
    init(title: String, nickname: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.nickname = nickname
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            content
            
            VStack(alignment: .leading, spacing: 8) {
                Text.keyme(title, font: .body5)
                    .foregroundColor(.white.opacity(0.3))
                
                Text.keyme("친구들이 생각하는\n\(nickname)님의 성격은?", font: .heading1)
                    .foregroundColor(.white)
                
                Spacer()
                horizontalSpacer
            }
            .padding(20)
        }
    }
    
    private var horizontalSpacer: some View {
        HStack { Spacer() }
    }
}

struct Knob: View {
    @Binding private var angle: Angle
    @State private var currentAngle: Angle
    
    init(angle: Binding<Angle>) {
        self._angle = angle
        self.currentAngle = angle.wrappedValue
    }

    var body: some View {
        GeometryReader { proxy in
            Circle()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .overlay(
                    Circle()
                        .fill(Gradient(colors: [.white, .blue]))
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .rotationEffect(angle)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let dx = value.translation.width
                                    let width = proxy.size.width
                                    
                                    let radians = (Double(dx) / (width/2) * .pi).between(min: -.pi, max: .pi)
                                    let newAngle = Angle(radians: radians)
                                    
                                    if newAngle.degrees.truncatingRemainder(dividingBy: 10.0) == 0 {
                                        HapticManager.shared.selectionChanged()
                                    }
                                    
                                    angle = currentAngle + newAngle
                                }
                                .onEnded { _ in
                                    currentAngle = angle
                                }
                        )
                )
        }
    }
}
