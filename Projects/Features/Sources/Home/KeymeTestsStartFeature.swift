//
//  KeymeTestsStartFeature.swift
//  Features
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import CoreFoundation
import ComposableArchitecture

import Domain

public struct KeymeTestsStartFeature: Reducer {
    public struct State: Equatable {
        public let nickname: String
        public let testData: KeymeTestsModel

        public var icon: IconModel = .EMPTY
        public var keymeTests: KeymeTestsFeature.State?
        public var isAnimating: Bool = false
        
        public init(nickname: String, testData: KeymeTestsModel) {
            self.nickname = nickname
            self.testData = testData
        }
    }
    
    public enum Action {
        case viewWillAppear
        case startAnimation([IconModel])
        case setIcon(IconModel)
        case startButtonDidTap
        case keymeTests(KeymeTestsFeature.Action)
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.keymeTestsClient) var keymeTestsClient
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewWillAppear:
                state.isAnimating = true
                return .send(.startAnimation(state.testData.icons))
                
            case .startAnimation(let icons):
                return .run { send in
                    repeat {
                        for icon in icons {
                            await send(.setIcon(icon))
                            try await self.clock.sleep(for: .seconds(1.595))
                        }
                    } while true
                }
                
            case let .setIcon(icon):
                state.icon = icon
                state.isAnimating = true
                
            case .startButtonDidTap:
                let url = "https://keyme-frontend.vercel.app/test/\(state.testData.testId)"
                state.keymeTests = KeymeTestsFeature.State(url: url)
                
            case .keymeTests:
                return .none
            }
            
            return .none
        }
        .ifLet(\.keymeTests, action: /Action.keymeTests) {
            KeymeTestsFeature()
        }
    }
}
