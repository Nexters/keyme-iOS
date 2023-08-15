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
    private let metadata: CircleMetadata
    
    public init(metadata: CircleMetadata) {
        self.metadata = metadata
    }
    
    public var body: some View {
        VStack(spacing: 13) {
            metadata.icon
                .resizable()
                .frame(width: 48, height: 48)
                .scaledToFit()

            VStack(spacing: 0) {
                Text(metadata.keyword)
                    .font(.Keyme.body3Semibold)
                
                Text(String(format: "%.1f", metadata.score))
                    .font(.Score.mypage)
            }
        }
        .foregroundColor(.white)
    }
}
