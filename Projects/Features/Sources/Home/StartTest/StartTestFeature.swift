//
//  StartTestFeature.swift
//  Features
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import CoreFoundation
import ComposableArchitecture

import Domain

public struct StartTestFeature: Reducer {
    public struct State: Equatable {
        public let nickname: String
        public let testData: KeymeTestsModel
        let authorizationToken: String

        public var icon: IconModel = .EMPTY
        @PresentationState public var keymeTestsState: KeymeTestsFeature.State?
        public var isAnimating: Bool = false
        
        public init(nickname: String, testData: KeymeTestsModel, authorizationToken: String) {
            self.nickname = nickname
            self.testData = testData
            self.authorizationToken = authorizationToken
        }
    }
    
    public enum Action {
        case viewWillAppear
        case startAnimation([IconModel])
        case setIcon(IconModel)
        case startButtonDidTap
        case keymeTests(PresentationAction<KeymeTestsFeature.Action>)
        case toggleAnimation(IconModel)
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.keymeTestsClient) var keymeTestsClient
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewWillAppear:
                return .send(.startAnimation(state.testData.tests.map { $0.icon }))
                
            case .startAnimation(let icons):
                
                return .run { send in
                    repeat {
                        for icon in icons {
                            await send(.toggleAnimation(icon))
                            try await self.clock.sleep(for: .seconds(0.85))
                        }
                    } while true
                }
                
            case let .setIcon(icon):
                state.icon = icon
                
            case .startButtonDidTap:
                let url = "https://keyme-frontend.vercel.app/test/\(state.testData.testId)"
                state.keymeTestsState = KeymeTestsFeature.State(url: url, authorizationToken: state.authorizationToken)
                print(state.keymeTestsState)
                
            case .keymeTests(.presented(.close)):
                state.keymeTestsState = nil
                
            case let .toggleAnimation(icon):
                state.isAnimating.toggle()
                
                return .run {[isAnimating = state.isAnimating] send in
                    while !isAnimating {
                        try await self.clock.sleep(for: .seconds(1))
                    }
                    await send(.setIcon(icon))
                }
                
            default:
                break
            }
            
            return .none
        }
        .ifLet(\.$keymeTestsState, action: /Action.keymeTests) {
            KeymeTestsFeature()
        }
    }
}
