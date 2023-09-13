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
import Domain

public struct StartTestView: View {
    public var store: StoreOf<StartTestFeature>
    
    public init(store: StoreOf<StartTestFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                    .frame(height: 75)
                
                welcomeText(nickname: viewStore.nickname)
                
                Spacer()
                
                startTestsButton(viewStore)
                    .onTapGesture {
                        viewStore.send(.startButtonDidTap)
                    }
                    .navigationDestination(
                        store: store.scope(
                            state: \.$keymeTestsState,
                            action: StartTestFeature.Action.keymeTests
                        ), destination: { store in
                            KeymeTestsView(store: store)
                                .ignoresSafeArea(.all)
                                .transition(.scale.animation(.easeIn))
                        })
                
                Spacer()
            }
            .background {
                // 웹뷰 로딩속도 개선 때문에 거의 안 보일 정도로 미리 띄워놓는 것임
                warmUpWebView()
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        .onDisappear {
            store.send(.stopAnimation)
        }
    }
}

extension StartTestView {
    func warmUpWebView() -> some View {
        let store: StoreOf<KeymeTestsFeature> = Store(
            initialState: KeymeTestsFeature.State(url: "", authorizationToken: "")
        ) {
            KeymeTestsFeature()
        }
        
        return KeymeTestsView(store: store).opacity(0.001)
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
                .animation(.spring(response: 0.85), value: viewStore.isAnimating)
            
            Circle()
                .foregroundColor(viewStore.icon.color)
                .frame(width: 110, height: 110)
                .scaleEffect(viewStore.isAnimating ? 1.0 : 0.001)
                .animation(.spring(response: 0.8), value: viewStore.isAnimating)
            
            KFImageManager.shared.toImage(url: viewStore.icon.imageURL)
                .frame(width: 30, height: 30)
                .scaledToFit()
                .scaleEffect(viewStore.isAnimating ? 1.0 : 0.001)
                .animation(.spring(response: 0.8), value: viewStore.isAnimating)
        }
    }
    
    func welcomeText(nickname: String) -> some View {
        Text.keyme(
            "환영해요 \(nickname)님!\n이제 문제를 풀어볼까요?",
            font: .heading1)
        .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
    }
}
