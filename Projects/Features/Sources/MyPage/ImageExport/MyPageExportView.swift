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

struct ScreenImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

public struct ImageExportOverlayFeature: Reducer {
    public struct State: Equatable {
        let title: String
        let nickname: String
        
        var isEditMode = true
    }
    
    public enum Action: Equatable {
        case dismissImageExportMode
        case enableEditMode(Bool)
        case captureImage
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .enableEditMode(let enabled):
                state.isEditMode = enabled
                
            default:
                break
            }
            
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
                    
                    Group {
                        if viewStore.isEditMode {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.white)
                                
                                CustomSlider(value: $rotationAngle.degrees, range: -Double.pi...Double.pi)
                            }
                        } else {
                            Text("Something")
                        }
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
                    Text.keyme("자랑하기", font: .body4)
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
