//
//  CircleContentView.swift
//  DSKit
//
//  Created by Young Bin on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Domain
import SwiftUI

public struct CircleContentView: View {
    var showSubText: Bool
    private let namespace: Namespace.ID
    private let metadata: CircleMetadata
    private let imageSize: CGFloat
    
    public init(namespace: Namespace.ID, metadata: CircleMetadata, imageSize: CGFloat) {
        self.init(namespace: namespace, metadata: metadata, showSubText: true, imageSize: imageSize)
    }
    
    public init(namespace: Namespace.ID, metadata: CircleMetadata, showSubText: Bool, imageSize: CGFloat) {
        self.namespace = namespace
        self.metadata = metadata
        self.showSubText = showSubText
        self.imageSize = imageSize
    }
    
    public var body: some View {
        VStack(spacing: imageSize / 4) {
            metadata.icon
                .resizable()
                .scaledToFit()
                .frame(height: imageSize)
                .opacity(showSubText ? 0.6 : 1)
                .matchedGeometryEffect(id: contentIconEffectID, in: namespace)
            
            if showSubText {
                VStack(spacing: 0) {
                    Text(metadata.keyword)
                        .font(.Keyme.body3Semibold)
                    
                    Text(String(format: "%.1f", metadata.averageScore))
                        .font(.Score.mypage)
                }
                .matchedGeometryEffect(id: contentTextEffectID, in: namespace)
                .transition(.opacity)
            }
        }
        .foregroundColor(.white)
    }
}

extension CircleContentView: GeometryAnimatableCircle {
    public var id: String {
        metadata.id.uuidString
    }
}
