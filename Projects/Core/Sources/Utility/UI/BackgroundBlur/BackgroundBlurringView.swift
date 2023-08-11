//
//  BackgroundBlurView.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/07/26.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

struct BackgroundBlurringView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: UIViewRepresentableContext<BackgroundBlurringView>) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<BackgroundBlurringView>) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
