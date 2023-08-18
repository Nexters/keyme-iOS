//
//  TestResultFeature.swift
//  Features
//
//  Created by 김영인 on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture

import Domain

public struct TestResultFeature: Reducer {
    public struct State: Equatable {
        @BindingState var testResult: TestResultModel = .EMPTY
        public var testResultId: Int
        public var testResults: [TestResultModel] = []
        
        public init(testResultId: Int) {
            self.testResultId = testResultId
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case viewWillAppear
        case fetchTestResult(TaskResult<[TestResultModel]>)
        case closeButtonDidTap
        case shareButtonDidTap
    }
    
    @Dependency(\.keymeTestsClient) var keymeTestsClient
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .viewWillAppear:
                return .run { [testResultId = state.testResultId] send in
                    await send(.fetchTestResult(
                        TaskResult { try await self.keymeTestsClient.fetchTestResult(testResultId) }
                    ))
                }
                
            case let .fetchTestResult(.success(results)):
                state.testResults = results
                state.testResult = results.first ?? TestResultModel.EMPTY
                
            case .fetchTestResult(.failure):
                return .none
                
            case .shareButtonDidTap:
                return .none    // TODO: 공유하기 버튼 구현
                
            default:
                return .none
            }
            
            return .none
        }
    }
}
