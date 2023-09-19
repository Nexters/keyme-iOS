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
    @StateObject var webViewSetup = KeymeWebViewSetup()

    private let store: StoreOf<OnboardingFeature>
    
    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                IfLetStore(
                    self.store.scope(
                        state: \.testResultState,
                        action: { .testResult($0) }
                    ), then: {
                        TestResultView(store: $0)
                            .transition(.opacity)
                    }, else: {
                        IfLetStore(
                            self.store.scope(
                                state: \.$keymeTestsState,
                                action: OnboardingFeature.Action.keymeTests
                            ),
                            then: { store in
                                KeymeTestsView(store: store)
                                    .ignoresSafeArea(.all)
                                    .environmentObject(webViewSetup)
                                    .transition(
                                        .scale.combined(with: .opacity)
                                        .animation(Animation.customInteractiveSpring(duration: 1)))
                            },
                            else: {
                                splashLottieView(viewStore)
                            }
                        )
                    }
                )
            }
            .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
            .ignoresSafeArea()
        }
    }
    
    func splashLottieView(_ viewStore: ViewStore<OnboardingFeature.State, OnboardingFeature.Action>) -> some View {
        ZStack {
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
            
            splashFrontView(viewStore)
        }
        .transition(
            .asymmetric(insertion: .identity, removal: .scale)
            .animation(Animation.customInteractiveSpring(duration: 1)))
    }
    
    func splashFrontView(_ viewStore: ViewStore<OnboardingFeature.State, OnboardingFeature.Action>) -> some View {
        VStack {
            Spacer()
                .frame(height: 119)
            
            Group {
                if case .question = viewStore.lottieType {
                    Text.keyme("환영해요 \(viewStore.nickname)님!\n이제 문제를 풀어볼까요?", font: .heading1)
                } else {
                    Text.keyme(viewStore.lottieType.title, font: .heading1)
                }
            }
            .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
            .padding(Padding.insets(leading: 16))
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(Animation.customInteractiveSpring(), value: viewStore.lottieType)
            
            Spacer()
            
            actionButton(for: viewStore.lottieType)
                .onTapGesture {
                    HapticManager.shared.boong()
                    viewStore.send(
                        viewStore.lottieType == .question ? .startButtonDidTap : .nextButtonDidTap
                    )
                }
                .padding(Padding.insets(leading: 16, trailing: 16))
                .frame(height: 60)
                .opacity(viewStore.isButtonShown ? 1.0 : 0.0)
                .animation(Animation.customInteractiveSpring(), value: viewStore.isButtonShown)
            
            Spacer()
                .frame(height: 54)
        }
        .frame(maxWidth: .infinity)
    }
}

private extension OnboardingView {
    func actionButton(for lottieType: LottieType) -> some View {
        let buttonText: String
        switch lottieType {
        case .splash1, .splash2, .splash3:
            buttonText = "다음"
        case .question:
            buttonText = "시작하기"
        }
        
        return ZStack {
            Rectangle()
                .cornerRadius(16)
                .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
            
            Text(buttonText)
                .font(Font(DSKitFontFamily.Pretendard.bold.font(size: 18)))
                .foregroundColor(.black)
        }
    }
}
