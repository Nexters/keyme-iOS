//
//  UpArrowButton.swift
//  DSKit
//
//  Created by Young Bin on 2023/08/13.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Core

public struct UpArrowButton: View {
    let white = DSKitAsset.Color.keymeWhite
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(
                    white.swiftUIColor.opacity(0.2))
            
            Image(systemName: "chevron.up")
                .resizable()
                .padding(7)
                .scaledToFit()
        }
        .overlay {
            Circle()
                .stroke(white.swiftUIColor, lineWidth: 1)
        }
    }
}
