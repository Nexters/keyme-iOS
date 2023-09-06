//
//  StartTestView.swift
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

public struct StartTestView: View {
    public var store: StoreOf<StartTestFeature>
    
    public init(store: StoreOf<StartTestFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            startTestsButton(viewStore)
                .onTapGesture {
                    viewStore.send(.startButtonDidTap)
                }
                .navigationDestination(
                    store: store.scope(
                        state: \.$keymeTests,
                        action: StartTestFeature.Action.keymeTests
                    ), destination: { store in
                        KeymeTestsView(store: store)
                            .ignoresSafeArea(.all)
                            .transition(.scale.animation(.easeIn))
                    })
        }
        .onAppear {
            store.send(.viewWillAppear)
        }
    }
    
    func startTestsButton(_ viewStore: ViewStore<StartTestFeature.State,
                          StartTestFeature.Action>) -> some View {
        ZStack {
            Circle()
                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                .background(Circle().foregroundColor(.white.opacity(0.3)))
                .frame(width: 280, height: 280)
                .scaleEffect(viewStore.isAnimating ? 1.0 : 0.8)
                .shadow(color: .white.opacity(0.3), radius: 30, x: 0, y: 10)
                .animation(.spring(response: 0.8).repeatForever(), value: viewStore.isAnimating)
            
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
