//
//  CircleAndScoreListView.swift
//  Features
//
//  Created by 이영빈 on 9/25/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

public struct CircleAndScoreListFeature: Reducer {
    public struct State: Equatable {}
    public enum Action: Equatable {}
    
    public var body: some ReducerOf<Self> {
        Reduce { _, _ in
            return .none
        }
    }
}

struct CircleAndScoreListView: View {
    private let store: StoreOf<CircleAndScoreListFeature>
    
    init(store: StoreOf<CircleAndScoreListFeature>) {
        self.store = store
    }
    
    var body: some View {
        Text("TT")
    }
}
