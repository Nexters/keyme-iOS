//
//  RootView.swift
//  Keyme
//
//  Created by 이영빈 on 2023/08/09.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import ComposableArchitecture
import Features

struct RootView: View {
    private let store = Store(
        initialState: KeymeServiceStatusFeature.State(),
        reducer: { KeymeServiceStatusFeature()._printChanges() })
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.logInStatus == .loggedOut {
                // 회원가입을 하지 않았거나 로그인을 하지 않은 유저
                let loginStore = store.scope(
                    state: \.$logInStatus,
                    action: KeymeServiceStatusFeature.Action.login)
                
                IfLetStore(loginStore) { store in
                    LoginView(store: store)
                }
            } else if viewStore.onboardingStatus == .needsOnboarding {
                // 가입했지만 온보딩을 하지 않고 종료했던 유저
                // 회원가입을 하지 않았거나 로그인을 하지 않은 유저
                let onboardingStore = store.scope(
                    state: \.$onboardingStatus,
                    action: KeymeServiceStatusFeature.Action.onboarding)
                
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
