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
        
        case showErrorAlert(message: String)
        
        public enum View: Equatable {
            case showResult(data: KeymeWebViewModel)
            case closeButtonTapped
            case closeWebView
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
                state.alertState = AlertState.information(title: "", message: "테스트를 종료하시겠어요?", actions: {
                    ButtonState(
                        role: .cancel,
                        label: { TextState("취소") }
                    )
                    ButtonState(
                        action: .closeTest,
                        label: { TextState("종료") }
                    )
                })
                
            case .view(.showResult(let data)):
                return .run { [resultCode = data.resultCode] send in
                    guard let resultCode else {
                        await send(.showErrorAlert(message: "데이터 조회 중 오류가 발생했어요. 잠시 후 다시 시도해주세요."))
                        return
                    }
                    
                    await send(.postResult(
                        TaskResult { try await
                            self.keymeTestsClient.postTestResult(resultCode)
                        }
                    ))
                }
                
            case .view(.closeWebView):
                return .send(.close)

            case .submit:
                return .none
                
            case .showErrorAlert(let message):
                state.alertState = AlertState.errorWithMessage(message)
                
            case .alert(.presented(.closeTest)):
                return .send(.close)
                
            default:
                return .none
            }
            
            return .none
        }
    }
}
