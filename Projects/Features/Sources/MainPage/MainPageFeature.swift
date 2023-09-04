//
//  MainPageFeature.swift
//  Features
//
//  Created by 이영빈 on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Core

public struct MainPageFeature: Reducer {
    public struct State: Equatable {
        @Box var home: KeymeTestsHomeFeature.State
        @Box var myPage: MyPageFeature.State
        
        public init(userId: Int, nickname: String) {
            self._home = .init(.init(nickname: nickname))
            self._myPage = .init(.init(userId: userId, nickname: nickname))
        }
    }
    
    public enum Action {
        case home(KeymeTestsHomeFeature.Action)
        case myPage(MyPageFeature.Action)
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.home, action: /Action.home) {
            KeymeTestsHomeFeature()
        }
        
        Scope(state: \.myPage, action: /Action.myPage) {
            MyPageFeature()
        }
        
        Reduce { _, action in
            switch action {
            case .myPage(.setting(.logout)):
                print("logout from mainpage")
            default:
                break
            }
            return .none
        }
    }
}
