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

// MARK: MMVP에 한해서 Daily 테스트를 Onboarding 테스트로 대체합니다.
public struct HomeFeature: Reducer {
    @Dependency(\.keymeAPIManager) private var network
    
    // 테스트를 아직 풀지 않았거나, 풀었거나 2가지 케이스만 존재
    public struct State: Equatable {
        @PresentationState var alertState: AlertState<Action.Alert>?
        @PresentationState var startTestState: StartTestFeature.State?
        @PresentationState var dailyTestListState: DailyTestListFeature.State?
        @PresentationState var scoreListState: CircleAndScoreListFeature.State?
        
        var authorizationToken: String? {
            @Dependency(\.keymeAPIManager.authorizationToken) var authorizationToken
            return authorizationToken
        }
        var view: View
        
        struct View: Equatable {
            var nickname: String {
                @Dependency(\.commonVariable) var commonVariable
                return commonVariable.nickname
            }
            let userId: Int
            var testId: Int
            var isSolvedDailyTest: Bool?
        }
        
        public init(userId: Int, testId: Int) {
            self.view = View(userId: userId, testId: testId)
        }
    }
    
    public enum Action {
        case onDisappear
        case requestLogout
        
        case fetchDailyTests
        case saveIsSolved(Bool)
        case saveTestId(Int)
        case showTestStartView(testData: KeymeTestsModel)
        case showTestResultView(testData: KeymeTestsModel)
        case showScoreList(circleData: CircleData)
        case showErrorAlert(HomeFeatureError)

        case alert(PresentationAction<Alert>)
        case startTest(PresentationAction<StartTestFeature.Action>)
        case dailyTestList(PresentationAction<DailyTestListFeature.Action>)
        case circleAndScoreList(PresentationAction<CircleAndScoreListFeature.Action>)
        
        enum View {}
        
        public enum Alert: Equatable {
            case error(HomeFeatureError)
        }
        
        public enum HomeFeatureError: LocalizedError {
            case cannotGetAuthorizationInformation
            case cannotGenerateTestLink
            case network
            
            public var errorDescription: String? {
                switch self {
                case .cannotGetAuthorizationInformation:
                    return "로그인 정보를 불러올 수 없습니다. 다시 로그인을 진행해주세요."
                    
                case .cannotGenerateTestLink:
                    return "링크를 생성할 수 없습니다. 잠시 후 다시 시도해주세요."
                
                case .network:
                    return ""
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
                    // MARK: 나중에 daily로 변경
                    let fetchedTest = try await network.request(.test(.onboarding), object: KeymeTestsDTO.self)
                    
                    let testData = fetchedTest.toKeymeTestsModel()
                    
                    await send(.saveIsSolved(fetchedTest.isSolved))
                    await send(.saveTestId(testData.testId))
                    
                    if !fetchedTest.isSolved {
                        await send(.showTestStartView(testData: testData))
                    } else {
                        await send(.showTestResultView(testData: testData))
                    }
                } catch: { _, send in
                    await send(.showErrorAlert(.network))
                }
                
            case let .saveIsSolved(isSolved):
                state.view.isSolvedDailyTest = isSolved
                
            case let .saveTestId(testId):
                state.view.testId = testId
                
            case .showTestStartView(let testData):
                guard let authorizationToken = state.authorizationToken else {
                    return .send(.showErrorAlert(.cannotGetAuthorizationInformation))
                }
                
                state.startTestState = StartTestFeature.State(
                    testData: testData,
                    authorizationToken: authorizationToken
                )

            case .showTestResultView(let testData):
                guard state.authorizationToken != nil else {
                    return .send(.showErrorAlert(.cannotGetAuthorizationInformation))
                }
                
                state.dailyTestListState = DailyTestListFeature.State(
                    testData: testData
                )
                
            case .showScoreList(let circleData):
                state.scoreListState = CircleAndScoreListFeature.State(circleData: circleData)
                
            case .showErrorAlert(let error):
                if case .network = error {
                    state.alertState = .errorWhileNetworking
                    return .none
                }
                
                state.alertState = .errorWithMessage(
                    error.localizedDescription,
                    actions: {
                        ButtonState(action: .error(.cannotGetAuthorizationInformation), label: { TextState("닫기") })
                    })
                return .none
                
            // MARK: Child stores
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
        .ifLet(\.$alertState, action: /Action.alert)
        .ifLet(\.$startTestState, action: /Action.startTest) {
            StartTestFeature()
        }
        .ifLet(\.$dailyTestListState, action: /Action.dailyTestList) {
            DailyTestListFeature()
        }
        .ifLet(\.$scoreListState, action: /Action.circleAndScoreList) {
            CircleAndScoreListFeature()._printChanges()
        }
    }
}
