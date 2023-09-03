//
//  KeymeTestsFeature.swift
//  Features
//
//  Created by 김영인 on 2023/08/17.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture

import Domain
import Network

public struct KeymeTestsFeature: Reducer {
    
    public struct State: Equatable {
        let url: String
        var authorizationToken: String? {
            @Dependency(\.keymeAPIManager.authorizationToken) var authorizationToken
            return authorizationToken
        }
        
        public init(url: String) {
            self.url = url
        }
    }
    
    public enum Action: Equatable {
        case transition
        case close
        case submit(resultCode: String, testResultId: Int)
        case showResult(data: KeymeWebViewModel)
        case postResult(TaskResult<String>)
    }
    
    @Dependency(\.keymeTestsClient) var keymeTestsClient
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .transition:
                return .none
            case .close:
                return .none
            case .submit(let code, let id):
                return .none
            case .showResult(let data):
                return .run { [resultCode = data.resultCode] send in
                    await send(.postResult(
                        TaskResult { try await
                            self.keymeTestsClient.postTestResult(resultCode)
                        }
                    ))
                }
            default:
                return .none
            }
        }
    }
}
