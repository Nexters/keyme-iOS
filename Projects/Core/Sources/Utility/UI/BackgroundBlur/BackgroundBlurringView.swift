//
//  BackgroundBlurView.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/07/26.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

/// 이 뷰를 만들면 이 뷰 뒷배경이 다 블러처리 된답니다
public struct BackgroundBlurringView: UIViewRepresentable {
    public var style: UIBlurEffect.Style
    
    public init(style: UIBlurEffect.Style) {
        self.style = style
    }

    public func makeUIView(context: UIViewRepresentableContext<BackgroundBlurringView>) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    public func updateUIView(
        _ uiView: UIVisualEffectView,
        context: UIViewRepresentableContext<BackgroundBlurringView>
    ) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
