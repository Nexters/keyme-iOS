//
//  CustomProgressView.swift
//  Core
//
//  Created by ab180 on 2023/09/27.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public struct CustomProgressView: View {
    public init() {}
    
    public var body: some View {
        ProgressView().tint(Color.white)
    }
}

public extension View {
    func fullscreenProgressView(isShown: Bool) -> some View {
        self.modifier(FullScreenProgressView(isShown: isShown))
    }
}

private struct FullScreenProgressView: ViewModifier {
    let isShown: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .zIndex(0)
            
            if isShown {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .zIndex(1)
                
                CustomProgressView()
                    .zIndex(2)
                    .center()
            }
        }
    }
}
