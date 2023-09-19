//
//  KeymeTestsView.swift
//  Features
//
//  Created by 김영인 on 2023/08/17.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import ComposableArchitecture
import DSKit

public struct KeymeTestsView: View {
    @EnvironmentObject var webViewSetup: KeymeWebViewSetup
    let store: StoreOf<KeymeTestsFeature>
    
    public init(store: StoreOf<KeymeTestsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }, send: KeymeTestsFeature.Action.view) { viewStore in
            ZStack {
                KeymeWebView(
                    url: viewStore.url,
                    accessToken: viewStore.authorizationToken
                )
                .onCloseWebView {
                    viewStore.send(.closeButtonTapped)
                }
                .onTestSubmitted { testResult in
                    viewStore.send(.showResult(data: testResult))
                }
                .environmentObject(webViewSetup)
                .onAppear {
                    webViewSetup.load(url: viewStore.url, accessToken: viewStore.authorizationToken)
                }
                .onDisappear {
                    webViewSetup.load(url: "about:blank", accessToken: viewStore.authorizationToken)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(store: store.scope(state: \.$alertState, action: KeymeTestsFeature.Action.alert))
    }
}
