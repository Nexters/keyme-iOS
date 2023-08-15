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
    
    public init(namespace: Namespace.ID, metadata: CircleMetadata, showSubText: Bool) {
        self.namespace = namespace
        self.metadata = metadata
        self.showSubText = showSubText
    }
    
    public init(namespace: Namespace.ID, metadata: CircleMetadata) {
        self.namespace = namespace
        self.metadata = metadata
        self.showSubText = true
    }
    
    public var body: some View {
        VStack(spacing: 13) {
            metadata.icon
                .resizable()
                .frame(width: 48, height: 48)
                .scaledToFit()
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
