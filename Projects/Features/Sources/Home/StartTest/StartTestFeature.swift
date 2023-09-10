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
        case onAppear
        case onDisappear
        case startAnimation([IconModel])
        case setIcon(IconModel)
        case startButtonDidTap
        case keymeTests(PresentationAction<KeymeTestsFeature.Action>)
        case toggleAnimation(IconModel)
    }
    
    enum CancelID {
        case startTest
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.keymeTestsClient) var keymeTestsClient
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.startAnimation(state.testData.tests.map { $0.icon }))
                
            case .onDisappear:
                state.isAnimating = true
                return .cancel(id: CancelID.startTest)
                
            case .startAnimation(let icons):
                
                return .run { send in
                    repeat {
                        for icon in icons {
                            await send(.toggleAnimation(icon))
                            try await self.clock.sleep(for: .seconds(0.85))
                        }
                    } while true
                }
                .cancellable(id: CancelID.startTest)
                
            case let .setIcon(icon):
                state.icon = icon
                
            // TODO: 현재 문제 풀이 웹뷰로 안넘어감
            case .startButtonDidTap:
                let url = "https://keyme-frontend.vercel.app/test/\(state.testData.testId)"
                state.keymeTestsState = KeymeTestsFeature.State(url: url, authorizationToken: state.authorizationToken)
                
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
                .cancellable(id: CancelID.startTest)
                
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
