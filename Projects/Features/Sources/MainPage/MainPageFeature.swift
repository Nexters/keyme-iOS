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
        let userId: Int
        let nickname: String
        
        public init(userId: Int, nickname: String) {
            self.userId = userId
            self.nickname = nickname
        }
    }
    
    public enum Action {
        case logout
        case changeNickname(String)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { _, _ in
            return .none
        }
    }
}
