//
//  TestStore.swift
//  Features
//
//  Created by 김영인 on 2023/07/29.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture

import Domain

public struct TestStore: ReducerProtocol {
    public struct State: Equatable {
        var text: String?
        
        public init(text: String? = nil) {
            self.text = text
        }
    }
    
    public enum Action {
        case testResponse(TaskResult<TestModel>)
        case buttonDidTap
    }
    
    @Dependency(\.testClient) var testClient
    
    public init() { }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .testResponse(.success(textModel)):
                state.text = textModel.hello
            case .testResponse(.failure(_)):
                state.text = nil
            case .buttonDidTap:
                return .run { send in
                    await send(.testResponse(
                        TaskResult { try await self.testClient.fetchTest() }
                    ))
                }
            }
            return .none
        }
    }
}
