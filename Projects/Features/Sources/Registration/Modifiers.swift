//
//  Modifiers.swift
//  Features
//
//  Created by 고도현 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

// 최대 글자 수를 넘기면 좌, 우로 떨리는 애니메이션
struct Shake: ViewModifier {
    @Binding var isShake: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: isShake ? -10 : 0) // 좌측으로 이동
            .animation(
                Animation
                    .easeInOut(duration: 0.1)
                    .repeatCount(3, autoreverses: true),
                value: isShake)
            .onChange(of: isShake) { newValue in
                if !newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            self.isShake = false
                        }
                    }
                }
            }
    }
}
