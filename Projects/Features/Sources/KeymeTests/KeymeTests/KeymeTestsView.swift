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
    let store: StoreOf<KeymeTestsFeature>
    
    public init(store: StoreOf<KeymeTestsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                KeymeWebView(url: viewStore.url)
                    .onCloseWebView {
                        print("close")
                    }
                    .onTestSubmitted { testResultId in
                        print(testResultId)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
