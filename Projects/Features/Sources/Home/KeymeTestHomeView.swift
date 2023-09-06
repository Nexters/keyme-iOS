//
//  KeymeTestHomeView.swift
//  Features
//
//  Created by 이영빈 on 2023/08/30.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import DSKit
import SwiftUI

struct KeymeTestsHomeView: View {
    var store: StoreOf<KeymeTestsHomeFeature>

    init(store: StoreOf<KeymeTestsHomeFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0.view }) { viewStore in
            ZStack(alignment: .center) {
                DSKitAsset.Color.keymeBlack.swiftUIColor.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    // Filler
                    Spacer().frame(height: 75)
                    
                    welcomeText(nickname: viewStore.nickname)
                        .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
                    
                    Spacer()
                }
                .fullFrame()
                .padding(.horizontal, 16)

                // 테스트 뷰
                testView

                // 결과 화면 표시도 생각
                
            }
            .onAppear {
                if viewStore.dailyTestId == nil {
                    viewStore.send(.fetchDailyTests)
                }
            }
        }
        .alert(store: store.scope(state: \.$alertState, action: KeymeTestsHomeFeature.Action.alert))
    }
}

extension KeymeTestsHomeView {
    var testView: some View {
        let startTestStore = store.scope(
            state: \.$testStartViewState,
            action: KeymeTestsHomeFeature.Action.startTest)
        
        return IfLetStore(startTestStore) { store in
            KeymeTestsStartView(store: store)
        } else: {
            Circle()
                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                .background(Circle().foregroundColor(.white.opacity(0.3)))
                .frame(width: 280, height: 280)
        }
    }
    
    func welcomeText(nickname: String) -> some View {
        Text.keyme(
            "환영해요 \(nickname)님!",
//            "환영해요 \(viewStore.nickname)님!\n이제 문제를 풀어볼까요?",
            font: .heading1)
    }
    
}
