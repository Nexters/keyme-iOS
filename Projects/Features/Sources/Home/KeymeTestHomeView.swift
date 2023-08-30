//
//  KeymeTestHomeView.swift
//  Features
//
//  Created by 이영빈 on 2023/08/30.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct KeymeTestsHomeView: View {
    var store: StoreOf<KeymeTestsHomeFeature>

    init(store: StoreOf<KeymeTestsHomeFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let startTestStore = store.scope(
                state: \.$testStartViewState,
                action: KeymeTestsHomeFeature.Action.startTest)
            
            IfLetStore(startTestStore) { store in
                KeymeTestsStartView(store: store)
            } else: {
                EmptyView()
            }

            // 결과 화면 표시도 생각
        }
    }
}
