//
//  ScoreAndPersonalityView.swift
//  DSKit
//
//  Created by Young Bin on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Domain
import SwiftUI

public struct ScoreAndPersonalityView: View {
    private let title: String
    private let score: Float
    
    public init(circleData: CircleData) {
        self.title = circleData.metadata.keyword
        self.score = circleData.metadata.averageScore
    }
    
    public init(title: String, score: Float) {
        self.title = title
        self.score = score
    }
    
    public var body: some View {
        // 상단에 점수표시
        VStack(spacing: 4) {
            Text.keyme(title, font: .body5)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white, lineWidth: 0.5)
                        }
                )
                .foregroundColor(.white)
            
            HStack(alignment: .bottom) {
                Text.keyme(score.toString(), font: .detailPage)

                Text.keyme("점", font: .caption1)
                    .offset(y: -7)
            }
            .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor.opacity(0.6))
        }
    }
}
