//
//  MyPageView.swift
//  Features
//
//  Created by Young Bin on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Domain
import SwiftUI

struct MyPageView: View {
    private let store: StoreOf<MyPageFeature>
    
    init(store: StoreOf<MyPageFeature>) {
        self.store = store
        store.send(.loadCircle)
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            CirclePackView(
                data: viewStore.state.circleDataList,
                detailViewBuilder: { data in
                    Text(data.id.uuidString)
                })
            .graphBackgroundColor(.hex("232323"))
            .activateCircleBlink(viewStore.state.shownFirstTime)
            .onCircleDismissed { _ in
                viewStore.send(.markViewAsShown)
            }
        }
    }
}
