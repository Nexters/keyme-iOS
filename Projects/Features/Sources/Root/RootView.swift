//
//  RootView.swift
//  Keyme
//
//  Created by 이영빈 on 2023/08/09.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

public struct RootView: View {
    private let store: StoreOf<RootFeature>
    
    public init() {
        self.store = Store(initialState: RootFeature.State()) {
            RootFeature()
        }
        
        store.send(.checkUserStatus)
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.logInStatus == .notDetermined {
                // 여기 걸리면 에러임. 조심하셈.
                EmptyView()
            } else if viewStore.logInStatus == .loggedOut {
                // 회원가입을 하지 않았거나 로그인을 하지 않은 유저
                let loginStore = store.scope(
                    state: \.$logInStatus,
                    action: RootFeature.Action.login)

                IfLetStore(loginStore) { store in
                    SignInView(store: store)
                }
            } else if viewStore.registrationState?.status == .notDetermined {
                // 개인정보 등록 상태를 로딩 중
                ProgressView()
            } else if viewStore.registrationState?.status == .needsRegister {
                // 개인정보 등록
                let registrationStore = store.scope(
                    state: \.$registrationState,
                    action: RootFeature.Action.registration)
                
                IfLetStore(registrationStore) { store in
                    RegistrationView(store: store)
                }
            } else if viewStore.onboardingStatus?.status == .notDetermined {
                // 온보딩 상태를 로딩 중
                ProgressView()
            } else if viewStore.onboardingStatus?.status == .needsOnboarding {
                // 가입했지만 온보딩을 하지 않고 종료했던 유저
                let onboardingStore = store.scope(
                    state: \.$onboardingStatus,
                    action: RootFeature.Action.onboarding)

                IfLetStore(onboardingStore) { store in
                    OnboardingView(store: store)
                }
            } else {
                // 가입했고 온보딩을 진행한 유저
                KeymeMainView(store: Store(
                    initialState: MainPageFeature.State()) {
                        MainPageFeature()
                    })
                .transition(.opacity)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
