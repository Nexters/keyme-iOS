//
//  KeymeLottie.swift
//  DSKit
//
//  Created by 김영인 on 2023/08/13.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Lottie
 
public struct KeymeLottieView: UIViewRepresentable {
    public let asset: AnimationAsset
    public let loopMode: LottieLoopMode
    
    public init(asset: AnimationAsset,loopMode: LottieLoopMode = .loop) {
        self.asset = asset
        self.loopMode = loopMode
    }
    
    public func makeUIView(context: Context) -> some UIView {
        let lottieView = LottieAnimationView(animation: asset.animation)
        
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.loopMode = loopMode
        lottieView.contentMode = .scaleToFill
        lottieView.play()
        
        let containerView = UIView(frame: .zero)
        containerView.addSubview(lottieView)
        NSLayoutConstraint.activate([
            lottieView.heightAnchor.constraint(equalTo: containerView.heightAnchor),
            lottieView.widthAnchor.constraint(equalTo: containerView.widthAnchor)
        ])
        return containerView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}