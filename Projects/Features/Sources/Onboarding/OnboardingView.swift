//
//  OnboardingView.swift
//  Keyme
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

import Core
import DSKit

public struct OnboardingView: View {
    private let store: StoreOf<OnboardingFeature>
    
    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                if let resultData = viewStore.resultData {
                    Text("Done")
                        .foregroundColor(.white)
                } else {
                    IfLetStore(
                        self.store.scope(
                            state: \.$keymeTestsState,
                            action: OnboardingFeature.Action.keymeTests
                        ),
                        then: { store in
                            KeymeTestsView(store: store)
                                .ignoresSafeArea(.all)
                                .transition(.scale.animation(.easeIn))
                        },
                        else: {
                            KeymeLottieView(asset: AnimationAsset.background,
                                            loopMode: .loop)
                            
                            if viewStore.isBlackBackground {
                                Rectangle()
                                    .foregroundColor(DSKitAsset.Color.keymeBlack.swiftUIColor)
                            } else {
                                BackgroundBlurringView(style: .systemMaterialDark)
                            }
                            
                            if viewStore.isLoop {
                                KeymeLottieView(asset: viewStore.lottieType.lottie,
                                                loopMode: .loop)
                            } else {
                                KeymeLottieView(asset: viewStore.lottieType.lottie) {
                                    viewStore.send(.lottieEnded)
                                }
                            }
                            
                            splashView(viewStore)
                        }
                    )
                }
            }
            .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
            .ignoresSafeArea()
        }
    }
    
    func splashView(_ viewStore: ViewStore<OnboardingFeature.State, OnboardingFeature.Action>) -> some View {
        VStack {
            Spacer()
                .frame(height: 119)
            
            Text.keyme(viewStore.lottieType.title, font: .heading1)
                .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
                .padding(Padding.insets(leading: 16))
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.easeIn(duration: 0.4), value: viewStore.lottieType)
            
            Spacer()
            
            if viewStore.lottieType == .question {
                Color.clear
                    .contentShape(Circle())
                    .onTapGesture {
                        viewStore.send(.startButtonDidTap)
                    }
            }
            
            Spacer()
            
            ZStack {
                Rectangle()
                    .cornerRadius(16)
                    .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
                
                Text("다음")
                    .font(Font(DSKitFontFamily.Pretendard.bold.font(size: 18)))
                    .foregroundColor(.black)
            }
            .onTapGesture {
                viewStore.send(.nextButtonDidTap)
            }
            .padding(Padding.insets(leading: 16, trailing: 16))
            .frame(height: 60)
            .opacity(viewStore.isButtonShown ? 1.0 : 0.0)
            .animation(.easeIn(duration: 0.5), value: viewStore.isButtonShown)
            
            Spacer()
                .frame(height: 54)
        }
        .frame(maxWidth: .infinity)
    }
}
