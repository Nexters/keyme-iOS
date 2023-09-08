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
        @Box var home: HomeFeature.State
        @Box var myPage: MyPageFeature.State
        
        var view: View = .none
        enum View: Equatable { case none }
        
        public init(userId: Int, nickname: String) {
            self._home = .init(.init(nickname: nickname))
            self._myPage = .init(.init(userId: userId, nickname: nickname))
        }
    }
    
    public enum Action {
        case home(HomeFeature.Action)
        case myPage(MyPageFeature.Action)
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.home, action: /Action.home) {
            HomeFeature()
        }
        
        Scope(state: \.myPage, action: /Action.myPage) {
            MyPageFeature()
        }
        
        Reduce { _, _ in
            return .none
        }
    }
}
