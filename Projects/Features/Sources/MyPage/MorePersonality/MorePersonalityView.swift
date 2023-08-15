//
//  MorePersonalityView.swift
//  Features
//
//  Created by Young Bin on 2023/08/13.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Domain
import DSKit

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
