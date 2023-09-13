//
//  HomeFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/30.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Domain
import Network
import Foundation

public struct HomeFeature: Reducer {
    @Dependency(\.keymeAPIManager) private var network
    
    // 테스트를 아직 풀지 않았거나, 풀었거나 2가지 케이스만 존재
    public struct State: Equatable {
        @PresentationState var alertState: AlertState<Action.Alert>?
        @PresentationState var startTestState: StartTestFeature.State?
        @PresentationState var dailyTestListState: DailyTestListFeature.State?
        var authorizationToken: String? {
            @Dependency(\.keymeAPIManager.authorizationToken) var authorizationToken
            return authorizationToken
        }
        var view: View
        
        struct View: Equatable {
            let nickname: String
            var dailyTestId: Int?
            var isSolvedDailyTest: Bool = false
            var testId: Int?
        }
        
        public init(nickname: String) {
            self.view = View(nickname: nickname)
        }
    }
    
    public enum Action {
        case onDisappear
        case requestLogout
        
        case fetchDailyTests
        case saveIsSolved(Bool)
        case saveTestId(Int)
        case showTestStartView(testData: KeymeTestsModel)
        case showErrorAlert(HomeFeatureError)

        case alert(PresentationAction<Alert>)
        case startTest(PresentationAction<StartTestFeature.Action>)
        case dailyTestList(PresentationAction<DailyTestListFeature.Action>)
        
        enum View {}
        
        public enum Alert: Equatable {
            case error(HomeFeatureError)
        }
        
        public enum HomeFeatureError: LocalizedError {
            case cannotGetAuthorizationInformation
            
            public var errorDescription: String? {
                switch self {
                case .cannotGetAuthorizationInformation:
                    return "로그인 정보를 불러올 수 없습니다. 다시 로그인을 진행해주세요."
                }
            }
        }
    }
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchDailyTests:
                return .run { send in
                    let fetchedTest = try await network.request(.test(.daily), object: KeymeTestsDTO.self)
//                    let fetchedTest = try await network.requestWithSampleData(.test(.onboarding), object: KeymeTestsDTO.self)
                    let testData = fetchedTest.toKeymeTestsModel()
                    await send(.saveIsSolved(fetchedTest.data.testResultId != nil))
                    await send(.saveTestId(testData.testId))
                    await send(.showTestStartView(testData: testData))
                }
                
            case let .saveIsSolved(isSolved):
                state.view.isSolvedDailyTest = isSolved
                
            case let .saveTestId(testId):
                state.view.testId = testId
                
            case .showTestStartView(let testData):
                state.view.dailyTestId = testData.testId
                guard let authorizationToken = state.authorizationToken else {
                    return .send(.showErrorAlert(.cannotGetAuthorizationInformation))
                }
                
                state.startTestState = StartTestFeature.State(
                    nickname: state.view.nickname,
                    testData: testData,
                    authorizationToken: authorizationToken
                )
                
                state.dailyTestListState =
                DailyTestListFeature.State(
                    testData: testData
                )
            case .showErrorAlert(let error):
                if case .cannotGetAuthorizationInformation = error {
                    state.alertState = AlertState.errorWithMessage(
                        error.localizedDescription,
                        actions: {
                            ButtonState(action: .error(.cannotGetAuthorizationInformation), label: { TextState("닫기") })
                        })
                }
                return .none
                
            case .alert(.presented(.error(let error))):
                if case .cannotGetAuthorizationInformation = error {
                    return .send(.requestLogout)
                }
                return .none
                
            default:
                break
            }
            
            return .none
        }
        .ifLet(\.$startTestState, action: /Action.startTest) {
            StartTestFeature()
        }
        .ifLet(\.$dailyTestListState, action: /Action.dailyTestList) {
            DailyTestListFeature()
        }
    }
}
