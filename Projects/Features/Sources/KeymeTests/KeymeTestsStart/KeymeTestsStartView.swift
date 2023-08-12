//
//  KeymeTestsStartView.swift
//  Features
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import ComposableArchitecture

import Util
import DSKit

public struct KeymeTestsStartView: View {
    @State private var isAnimation = false
    public var store: StoreOf<KeymeTestsStartFeature>
    
    public init(store: StoreOf<KeymeTestsStartFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                    .frame(height: 10)
                
                logoImage()
                
                Spacer()
                    .frame(height: 35)
                
                welcomeText(viewStore)
                
                Spacer()
                
                startTestsButton(viewStore)
                
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                viewStore.send(.viewWillAppear)
            }
            .background(Color(DSKitAsset.Color.keymeBlack.color.cgColor))
        }
    }
    
    func logoImage() -> some View {
    #warning("로고로 이미지 변경 필요")
        return Image(systemName: "eyes.inverse")
            .frame(width: 30, height: 30)
            .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
    }
    
    func welcomeText(_ viewStore: ViewStore<KeymeTestsStartFeature.State, KeymeTestsStartFeature.Action>) -> some View {
        Text("환영해요 \(viewStore.nickname ?? "")님!\n이제 문제를 풀어볼까요?")
            .font(Font.Keyme.heading1)
            .foregroundColor(DSKitAsset.Color.keymeWhite.swiftUIColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets.insets(leading: 16))
    }
    
    func startTestsButton(_ viewStore: ViewStore<KeymeTestsStartFeature.State,
                          KeymeTestsStartFeature.Action>) -> some View {
        ZStack {
            Circle()
                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                .background(Circle().foregroundColor(.white.opacity(0.3)))
                .frame(width: isAnimation ? 230 : 180, height: isAnimation ? 230 : 180)
                .shadow(color: .white.opacity(0.3), radius: 30, x: 0, y: 10)
            
            Circle()
                .foregroundColor(Color.hex(viewStore.state.icons.first?.color ?? ""))
                .frame(width: isAnimation ? 110 : 0, height: isAnimation ? 110 : 0)
            
            viewStore.state.icons.first?.image.toImage()
                .frame(width: isAnimation ? 30 : 0, height: isAnimation ? 30 : 0)
        }
        .onAppear {
            withAnimation(
                .easeIn(duration: 0.5)
                .delay(0.3)
                .repeatForever(autoreverses: true)
            ) {
                isAnimation.toggle()
            }
        }
    }
}

#warning("Util로 이동")
extension EdgeInsets {
    static func insets(top: CGFloat=0, leading: CGFloat=0, bottom: CGFloat=0, trailing: CGFloat=0) -> EdgeInsets {
        return EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}
