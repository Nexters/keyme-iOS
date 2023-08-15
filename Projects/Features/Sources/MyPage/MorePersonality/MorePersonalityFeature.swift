//
//  MorePersonalityFeature.swift
//  Features
//
//  Created by Young Bin on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Domain
import DSKit

struct MorePersonalityFeature: Reducer {
    public struct State: Equatable {
        var personalities: [Personality]
        
        public init() {
            self.personalities = [
                Personality(name: "닉네임", keyword: "꼰대력", averageScore: 3.5)
            ]
        }
    }
    public enum Action: Equatable {
        case loadPersonality
        case savePersonality([Personality])
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadPersonality:
                return .run { send in
                    try await Task.sleep(until: .now + .seconds(0.5), clock: .continuous)
                    await send(.savePersonality([
                        Personality(name: "닉네임", keyword: "꼰대력", averageScore: 3.5),
                        Personality(name: "닉네임", keyword: "꼰대력", averageScore: 3.5),
                        Personality(name: "닉네임", keyword: "꼰대력", averageScore: 3.5),
                        Personality(name: "닉네임", keyword: "꼰대력", averageScore: 3.5),
                        Personality(name: "닉네임", keyword: "꼰대력", averageScore: 3.5)
                    ]))
                }
                
            case .savePersonality(let data):
                state.personalities.append(contentsOf: data)
            }
            return .none
        }
    }
}
