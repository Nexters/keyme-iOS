//
//  MorePersonalityView.swift
//  Features
//
//  Created by Young Bin on 2023/08/13.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import DSKit

struct Personality: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let keyword: String
    let averageScore: Float
}

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

struct MorePersonalityView: View {
    let store: StoreOf<MorePersonalityFeature>
    
    init(store: StoreOf<MorePersonalityFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: \.personalities) { viewStore in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 13) {
                    Text("내 성격 더 보기")
                        .foregroundColor(keymeWhite)
                    
                    Divider()
                        .overlay(keymeWhite.opacity(0.1))
                    
                    ForEach(viewStore.state) { personality in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.red.opacity(0.5))
                                .frame(width: 40)
                            
                            VStack(alignment: .leading, spacing: 6.5) {
                                Text("\(personality.name)님의 \(personality.keyword) 정도는?")
                                    .font(.Keyme.body3Semibold)
                                    .foregroundColor(keymeWhite)
                                Text("평균점수 | \(String(format: "%.1f", personality.averageScore))점")
                                    .font(.Keyme.body4)
                                    .foregroundColor(keymeWhite.opacity(0.5))
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, minHeight: 85, maxHeight: 85)
                        .background(keymeWhite.opacity(0.05))
                        .cornerRadius(14)
                        .onAppear {
                            if
                                let thirdToLast = viewStore.state.dropLast(2).last,
                                thirdToLast == personality
                            {
                                viewStore.send(.loadPersonality)
                            }
                        }
                    }
                }
                .padding(.horizontal, 17)
            }
        }
    }
    
    var keymeWhite: Color {
        DSKitAsset.Color.keymeWhite.swiftUIColor
    }
}

struct MorePersonalityView_Previews: PreviewProvider {
    static var previews: some View {
        MorePersonalityView(store: Store(initialState: MorePersonalityFeature.State(), reducer: {
            MorePersonalityFeature()
        }))
    }
}
