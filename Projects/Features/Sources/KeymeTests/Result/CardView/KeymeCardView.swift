//
//  KeymeCardView.swift
//  Features
//
//  Created by 김영인 on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import Core
import Util
import DSKit
import Domain

public struct KeymeCardView: View {
    private let testResult: TestResultModel
    
    public init(testResult: TestResultModel) {
        self.testResult = testResult
    }
    
    public var body: some View {
        VStack {
            Spacer()
                .frame(height: 33)
            
            cardTopView()
                .padding(Padding.insets(leading: 33, trailing: 33))
            
            Spacer()
            
            circleView()
            
            Spacer()
        }
        .background(DSKitAsset.Color.keymeBottom.swiftUIColor)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    DSKitAsset.Color.keymeStrokegray.swiftUIColor,
                    lineWidth: 1
                )
        )
        .frame(width: 320, height: 490)
    }
    
    // 카드 상단 뷰 (키워드, 타이틀, 점수)
    func cardTopView() -> some View {
        VStack(alignment: .leading) {
            Text.keyme(testResult.title, font: .body4)
                .foregroundColor(.white.opacity(0.3))
            
            Spacer()
                .frame(height: 8)
            
            Text.keyme("\(testResult.nickname)의 애정표현 정도는?", font: .heading1)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Divider()
                .background(.white.opacity(0.1))
            
            HStack {
                Text.keyme("0\(testResult.score)", font: .checkResult)
                    .foregroundColor(.white.opacity(0.6))
                
                Text.keyme("점", font: .caption1)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
            }
        }
    }
    
    // 원모양 결과 뷰
    func circleView() -> some View {
        HStack {
            Spacer()
            
            ZStack(alignment: .center) {
                Circle()
                    .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                    .background(Circle().foregroundColor(.white.opacity(0.3)))
                    .frame(width: 280, height: 280)
                
                Circle()
                    .foregroundColor(testResult.icon.color)
                    .frame(width: scoreToRadius(score: testResult.score),
                           height: scoreToRadius(score: testResult.score))
                
                KFImageManager.shared.toImage(url: testResult.icon.imageURL)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
            }
            
            Spacer()
        }
    }
    
    func scoreToRadius(score: Int) -> CGFloat {
        return ((CGFloat(score) - 1) / (5 - 1) * (320 - 100) + 100) * 0.875
    }
}
