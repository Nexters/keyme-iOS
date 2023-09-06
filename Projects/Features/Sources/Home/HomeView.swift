//
//  HomeView.swift
//  Features
//
//  Created by 이영빈 on 2023/08/30.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import DSKit
import SwiftUI

public struct HomeView: View {
    public var store: StoreOf<HomeFeature>
    
    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0.view }) { viewStore in
            ZStack(alignment: .center) {
                DSKitAsset.Color.keymeBlack.swiftUIColor.ignoresSafeArea()
                
                #warning("testResultId로 분기처리 해야됨")
                //startTestView
                dailyTestListView
                
            }
            .onAppear {
                if viewStore.dailyTestId == nil {
                    viewStore.send(.fetchDailyTests)
                }
            }
        }
        .alert(store: store.scope(state: \.$alertState, action: HomeFeature.Action.alert))
    }
}

extension HomeView {
    var startTestView: some View {
        let startTestStore = store.scope(
            state: \.$startTestState,
            action: HomeFeature.Action.startTest
        )
        
        return IfLetStore(startTestStore) { store in
            StartTestView(store: store)
        } else: {
            Circle()
                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                .background(Circle().foregroundColor(.white.opacity(0.3)))
                .frame(width: 280 * 0.8, height: 280 * 0.8)
        }
    }
    
    var dailyTestListView: some View {
        let dailyTestListStore = store.scope(
            state: \.$dailyTestListState,
            action: HomeFeature.Action.dailyTestList
        )
        
        return IfLetStore(dailyTestListStore) { store in
            DailyTestListView(store: store)
        }
    }
}
