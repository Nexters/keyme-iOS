//
//  KeymeTestsStartView.swift
//  Features
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import ComposableArchitecture

import Core
import Util
import DSKit

public struct KeymeTestsStartView: View {
    public var store: StoreOf<KeymeTestsStartFeature>
    
    public init(store: StoreOf<KeymeTestsStartFeature>) {
        self.store = store
        store.send(.viewWillAppear)
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            IfLetStore(
                self.store.scope(
                    state: \.keymeTests,
                    action: KeymeTestsStartFeature.Action.keymeTests
                ),
                then: { store in
                    KeymeTestsView(store: store)
                        .ignoresSafeArea(.all)
                        .transition(.scale.animation(.easeIn))
                },
                else: {
                    startTestsButton(viewStore)
                        .onTapGesture {
                            viewStore.send(.startButtonDidTap)
                        }
                }
            )
        }
    }
    
    func startTestsButton(_ viewStore: ViewStore<KeymeTestsStartFeature.State,
                          KeymeTestsStartFeature.Action>) -> some View {
        ZStack {
            Circle()
                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                .background(Circle().foregroundColor(.white.opacity(0.3)))
                .frame(width: 280, height: 280)
                .scaleEffect(viewStore.isAnimating ? 1.0 : 0.8)
                .shadow(color: .white.opacity(0.3), radius: 30, x: 0, y: 10)
                .animation(.spring(response: 0.85).repeatForever(), value: viewStore.isAnimating)
            
            Circle()
                .foregroundColor(viewStore.icon.color)
                .frame(width: 110, height: 110)
                .scaleEffect(viewStore.isAnimating ? 1.0 : 0.001)
                .animation(.spring(response: 0.8).repeatForever(), value: viewStore.isAnimating)
            
            KFImageManager.shared.toImage(url: viewStore.icon.imageURL)
                .frame(width: 30, height: 30)
                .scaledToFit()
                .scaleEffect(viewStore.isAnimating ? 1.0 : 0.001)
                .animation(.spring(response: 0.8).repeatForever(), value: viewStore.isAnimating)
        }
    }
}
