//
//  CommonNavigationBar.swift
//  Features
//
//  Created by 이영빈 on 10/1/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

struct CommonNavigationBar: View {
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(width: 10, height: 20)
                    .scaledToFit()
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(.clear)
    }
}

struct CommonNavigationBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            CommonNavigationBar()
            content
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

extension View {
    func addCommonNavigationBar() -> some View {
        modifier(CommonNavigationBarModifier())
    }
}
