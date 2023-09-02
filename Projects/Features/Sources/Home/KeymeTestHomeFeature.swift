//
//  KeymeTestHomeFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/30.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Domain
import Network

public struct KeymeTestsHomeFeature: Reducer {
    @Dependency(\.keymeAPIManager) private var network
    
    // 테스트를 아직 풀지 않았거나, 풀었거나 2가지 케이스만 존재
    public struct State: Equatable {
        @PresentationState var testStartViewState: KeymeTestsStartFeature.State?
        var view: View
        
        struct View: Equatable {
            let nickname: String
            var dailyTestId: Int?
        }
        
        init(nickname: String) {
            self.view = View(nickname: nickname)
        }
    }
    
    public enum Action {
        case fetchDailyTests
        case showTestStartView(testData: KeymeTestsModel)
        case startTest(PresentationAction<KeymeTestsStartFeature.Action>)
        
        enum View {}
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchDailyTests:
                return .run { send in
                    let fetchedTest = try await network.request(.test(.daily), object: KeymeTestsDTO.self)
                    let testData = fetchedTest.toKeymeTestsModel()
                    
                    await send(.showTestStartView(testData: testData))
                }
                
            case .showTestStartView(let testData):
                state.view.dailyTestId = testData.testId
                state.testStartViewState = .init(nickname: state.view.nickname, testData: testData)
                
            default:
                break
            }
            
            return .none
        }
    }
}
