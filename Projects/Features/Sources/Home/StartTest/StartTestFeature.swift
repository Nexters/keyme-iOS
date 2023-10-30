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
    enum CancelID { case startAnimation }
    
    public struct State: Equatable {
        var nickname: String {
            @Dependency(\.commonVariable) var commonVariable
            return commonVariable.nickname
        }
        public let testData: KeymeTestsModel
        let authorizationToken: String

        public var icon: IconModel = .EMPTY
        @PresentationState public var keymeTestsState: KeymeTestsFeature.State?
        public var isAnimating: Bool = false
        
        public init(testData: KeymeTestsModel, authorizationToken: String) {
            self.testData = testData
            self.authorizationToken = authorizationToken
        }
    }
    
    public enum Action {
        case onAppear
        case onDisappear
        case startAnimation([IconModel])
        case stopAnimation
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
            case .onAppear:
                return .send(.startAnimation(state.testData.tests.map { $0.icon }))
                
            case .onDisappear:
                state.isAnimating = true
                
            case .startAnimation(let icons):
                return .run { send in
                    try await withTaskCancellation(
                        id: CancelID.startAnimation,
                        cancelInFlight: true
                    ) {
                        repeat {
                            for icon in icons {
                                await send(.toggleAnimation(icon))
                                try await self.clock.sleep(for: .seconds(0.85))
                            }
                        } while true
                    }
                }
                
            case .stopAnimation:
                return .cancel(id: CancelID.startAnimation)
                
            case let .setIcon(icon):
                state.icon = icon
                
            case .startButtonDidTap:
                let url = CommonVariable.testPageURLString(testId: state.testData.testId)
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
