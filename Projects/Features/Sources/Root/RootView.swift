//
//  RootView.swift
//  Features
//
//  Created by 이영빈 on 2023/09/04.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Core
import ComposableArchitecture
import DSKit

public struct RootView: View {
    @State private var showBlurringBackground = false
    private let store: StoreOf<RootFeature>
    
    public init() {
        self.store = Store(initialState: RootFeature.State.notDetermined) {
            RootFeature()
        }
        
        store.send(.view(.checkUserStatus))
    }
    
    public var body: some View {
        ZStack {
            // 애니메이션 부웅.. 부웅..
            KeymeLottieView(asset: .background, loopMode: .autoReverse)
                .ignoresSafeArea()
            
            SwitchStore(store) { state in
                if case .needSignIn = state {
                    EmptyView()
                } else {
                    BackgroundBlurringView(style: .dark)
                        .ignoresSafeArea()
                        .transition(.opacity.animation(Animation.customInteractiveSpring()))
                }
                
                switch state {
                case .needSignIn:
                    CaseLet(
                        /RootFeature.State.needSignIn,
                         action: RootFeature.Action.login
                    ) { store in
                        SignInView(store: store)
                    }
                    .zIndex(ViewZIndex.siginIn.rawValue)
                    .transition(.opacity.animation(Animation.customInteractiveSpring()))
                    
                case .needRegistration:
                    CaseLet(
                        /RootFeature.State.needRegistration,
                         action: RootFeature.Action.registration
                    ) { store in
                        RegistrationView(store: store)
                    }
                    .zIndex(ViewZIndex.registration.rawValue)
                    .transition(.opacity.animation(Animation.customInteractiveSpring()))

                case .needOnboarding:
                    CaseLet(
                        /RootFeature.State.needOnboarding,
                         action: RootFeature.Action.onboarding
                    ) { store in
                        OnboardingView(store: store)
                    }
                    .zIndex(ViewZIndex.onboarding.rawValue)
                    .transition(.opacity.animation(Animation.customInteractiveSpring()))

                case .canUseApp:
                    CaseLet(
                        /RootFeature.State.canUseApp,
                         action: RootFeature.Action.mainPage
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

private extension RootView {
    enum ViewZIndex: CGFloat {
        case siginIn = 4
        case registration = 3
        case onboarding = 2
        case main = 1
    }
}
