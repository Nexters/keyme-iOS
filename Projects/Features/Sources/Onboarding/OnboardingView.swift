//
//  OnboardingView.swift
//  Keyme
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

// FIXME: Temp
public struct OnboardingView: View {
    private let store: StoreOf<OnboardingFeature>
    
    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Button(action: { store.send(.succeeded) }) {
            Text("온보딩?")
        }
    }
}
