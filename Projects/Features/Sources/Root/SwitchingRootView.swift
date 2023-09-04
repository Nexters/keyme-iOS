//
//  SwitchingRootView.swift
//  Features
//
//  Created by 이영빈 on 2023/09/04.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Core
import ComposableArchitecture
import DSKit

public struct SwitchingRootView: View {
    @State private var showBlurringBackground = false
    private let store: StoreOf<SwitchingRootFeature>
    
    public init() {
        self.store = Store(initialState: SwitchingRootFeature.State.notDetermined) {
            SwitchingRootFeature()
        }
        
        store.send(.view(.checkUserStatus))
    }
    
    public var body: some View {
        ZStack {
            // 애니메이션 부웅.. 부웅..
            KeymeLottieView(asset: .background, loopMode: .autoReverse)
                .ignoresSafeArea()
            
            if showBlurringBackground {
                BackgroundBlurringView(style: .dark)
                    .ignoresSafeArea()
                    .transition(.opacity.animation(Animation.customInteractiveSpring()))
            }
            
            SwitchStore(store) { state in
                switch state {
                case .needSignIn:
                    CaseLet(
                        /SwitchingRootFeature.State.needSignIn,
                         action: SwitchingRootFeature.Action.login
                    ) { store in
                        SignInView(store: store)
                    }
                    .zIndex(ViewZIndex.siginIn.rawValue)
                    .transition(.opacity.animation(Animation.customInteractiveSpring()))
                    .onDisappear {
                        showBlurringBackground = true
                    }
                    
                case .needRegistration:
                    CaseLet(
                        /SwitchingRootFeature.State.needRegistration,
                         action: SwitchingRootFeature.Action.registration
                    ) { store in
                        RegistrationView(store: store)
                    }
                    .zIndex(ViewZIndex.registration.rawValue)
                    .transition(.opacity.animation(Animation.customInteractiveSpring()))

                case .needOnboarding:
                    CaseLet(
                        /SwitchingRootFeature.State.needOnboarding,
                         action: SwitchingRootFeature.Action.onboarding
                    ) { store in
                        OnboardingView(store: store)
                    }
                    .zIndex(ViewZIndex.onboarding.rawValue)
                    .transition(.opacity.animation(Animation.customInteractiveSpring()))

                case .canUseApp:
                    CaseLet(
                        /SwitchingRootFeature.State.canUseApp,
                         action: SwitchingRootFeature.Action.mainPage
                    ) { store in
                        KeymeMainView(store: store)
                    }
                    .zIndex(ViewZIndex.main.rawValue)
                    .transition(.opacity.animation(Animation.customInteractiveSpring()))

                default:
                    Text("")
                }
            }
        }
    }
}

private extension SwitchingRootView {
    enum ViewZIndex: CGFloat {
        case siginIn = 4
        case registration = 3
        case onboarding = 2
        case main = 1
    }
}
