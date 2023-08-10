//
//  LoginView.swift
//  Keyme
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Features
import ComposableArchitecture

// FIXME: Temp
struct LoginView: View {
    private let store: StoreOf<SignInFeature>
    
    init(store: StoreOf<SignInFeature>) {
        self.store = store
    }
    
    var body: some View {
        Button(action: { store.send(.succeeded) }) {
            Text("로그인?")
        }
    }
}
