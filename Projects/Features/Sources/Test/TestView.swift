//
//  TestView.swift
//  Features
//
//  Created by 김영인 on 2023/07/29.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import ComposableArchitecture

import DSKit

public struct TestView: View {
    public let store: StoreOf<TestStore>
    
    public init(store: StoreOf<TestStore>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 50) {
                Text(viewStore.text ?? "")
                    .font(Font.Keyme.body2)
                    .foregroundColor(DSKitAsset.Color.keymeBlack.swiftUIColor)
                
                DSKitAsset.Image.camera.swiftUIImage
                    .frame(width: 40, height: 40)
                
                Button("테스트 서버 호출하기") {
                    viewStore.send(.buttonDidTap)
                }
            }
        }
    }
}
