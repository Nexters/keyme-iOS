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
    @State private var showCloseAlert = false
    
    let store: StoreOf<KeymeTestsFeature>
    
    public init(store: StoreOf<KeymeTestsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                KeymeWebView(url: viewStore.url, accessToken: viewStore.authorizationToken ?? "") // TODO: handle it
                    .onCloseWebView {
                        showCloseAlert = true
                    }
                    .onTestSubmitted { testResult in
                        viewStore.send(.showResult(data: testResult))
                    }
                    .toolbar(.hidden, for: .navigationBar)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .alert("", isPresented: $showCloseAlert) {
                Button("취소", role: .cancel) { }
                Button("종료") { viewStore.send(.close) }
            } message: {
                Text("테스트를 종료하시겠어요?")
            }
        }
    }
}
