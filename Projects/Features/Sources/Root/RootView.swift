//
//  RootView.swift
//  Keyme
//
//  Created by 이영빈 on 2023/08/09.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Core
import ComposableArchitecture
import DSKit

public struct RootView: View {
    private let store: StoreOf<RootFeature>
    
    public init() {
        self.store = Store(initialState: RootFeature.State()) {
            RootFeature()._printChanges()
        }
        
        store.send(.view(.checkUserStatus))
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0.userStatus }, send: RootFeature.Action.view) { viewStore in
            ZStack {
                // 애니메이션 부웅.. 부웅..
                KeymeLottieView(asset: .background, loopMode: .autoReverse)
                    .ignoresSafeArea()
                
                if viewStore.state != .needSignIn {
                    BackgroundBlurringView(style: .dark)
                        .ignoresSafeArea()
                        .transition(.opacity.animation(.easeInOut))
                }
                
                switch viewStore.state {
                case .needSignIn:
                    // 회원가입을 하지 않았거나 로그인을 하지 않은 유저
                    let loginStore = store.scope(
                        state: \.$logInStatus,
                        action: RootFeature.Action.login)
                    
                    IfLetStore(loginStore) { store in
                        SignInView(store: store)
                    }
                    
                case .needRegistration:
                    // 개인정보 등록
                    let registrationStore = store.scope(
                        state: \.$registrationState,
                        action: RootFeature.Action.registration)
                    
                    IfLetStore(registrationStore) { store in
                        RegistrationView(store: store)
                    }
                
                case .needOnboarding:
                    // 가입했지만 온보딩을 하지 않고 종료했던 유저
                    let onboardingStore = store.scope(
                        state: \.$onboardingState,
                        action: RootFeature.Action.onboarding)
                    
                    IfLetStore(onboardingStore) { store in
                        OnboardingView(store: store)
                    }
                    
                case .canUseApp:
                    // 가입했고 온보딩을 진행한 유저
                    let mainPageStore = store.scope(
                        state: \.$mainPageState,
                        action: RootFeature.Action.mainPage)
                    
                    IfLetStore(mainPageStore) { store in
                        KeymeMainView(store: store)
                            .transition(.opacity.animation(.easeInOut))
                    } else: {
                        Text("에러")
                    }
                    
                case .notDetermined:
                    EmptyView()
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
