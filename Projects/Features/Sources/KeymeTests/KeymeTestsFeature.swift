//
//  KeymeTestsFeature.swift
//  Features
//
//  Created by 김영인 on 2023/08/17.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Foundation

import Domain
import Network

public struct KeymeTestsFeature: Reducer {
    
    public struct State: Equatable {
        let url: String
        let authorizationToken: String
        @PresentationState var alertState: AlertState<Action.Alert>?
        
        public init(url: String, authorizationToken: String) {
            self.url = url
            self.authorizationToken = authorizationToken
            self.alertState = alertState
        }
    }
    
    public enum Action: Equatable {
        case transition
        case close
        
        case submit(resultCode: String, testResultId: Int)
        case postResult(TaskResult<String>)
        
        case view(View)
        case alert(PresentationAction<Alert>)
        
        public enum View: Equatable {
            case showResult(data: KeymeWebViewModel)
            case closeButtonTapped
        }
        
        public enum Alert: Equatable {
            case closeTest
        }
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
                
            // MARK: - View actions
            case .view(.closeButtonTapped):
                state.alertState = AlertState(
                    title: { TextState("") },
                    actions: {
                        ButtonState(
                            role: .cancel,
                            label: { TextState("취소") }
                        )
                        ButtonState(
                            action: .closeTest,
                            label: { TextState("종료") }
                        )
                    },
                    message: { TextState("테스트를 종료하시겠어요?") })
                
            case .view(.showResult(let data)):
                return .run { [resultCode = data.resultCode] send in
                    await send(.postResult(
                        TaskResult { try await
                            self.keymeTestsClient.postTestResult(resultCode)
                        }
                    ))
                }

            case .submit:
                return .none
                
            case .alert(.presented(.closeTest)):
                return .send(.close)
                
            default:
                return .none
            }
            
            return .none
        }
    }
}
