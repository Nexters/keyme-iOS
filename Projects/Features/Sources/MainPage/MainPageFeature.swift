//
//  MainPageFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture

public struct MainPageFeature: Reducer {
    public struct State: Equatable {
        var home: KeymeTestsHomeFeature.State
        var myPage: MyPageFeature.State
        
        public init(userId: Int, nickname: String) {
            self.home = .init(nickname: nickname)
            self.myPage = .init(userId: userId, nickname: nickname)
        }
    }
    
    public enum Action {
        case home(KeymeTestsHomeFeature.Action)
        case myPage(MyPageFeature.Action)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { _, _ in
            return .none
        }
        
        Scope(state: \.home, action: /Action.home) {
            KeymeTestsHomeFeature()
        }
        
        Scope(state: \.myPage, action: /Action.myPage) {
            MyPageFeature()
        }
        
    }
}
