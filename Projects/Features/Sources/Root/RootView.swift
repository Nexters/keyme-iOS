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
            RootFeature()._printChanges()
        }
        
        store.send(.checkLoginStatus)
        store.send(.checkOnboardingStatus) // For 디버깅, 의도적으로 3초 딜레이
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
                    SignIninView(store: store)
                }
            } else if viewStore.onboardingStatus == .notDetermined {
                // 온보딩 상태를 로딩 중
                ProgressView()
            } else if viewStore.onboardingStatus == .needsOnboarding {
                // 가입했지만 온보딩을 하지 않고 종료했던 유저
                let onboardingStore = store.scope(
                    state: \.$onboardingStatus,
                    action: RootFeature.Action.onboarding)
                
                IfLetStore(onboardingStore) { store in
                    OnboardingView(store: store)
                }
            } else {
                // 가입했고 온보딩을 진행한 유저
                KeymeMainView()
            }
        }
    }
}

 struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
 }
