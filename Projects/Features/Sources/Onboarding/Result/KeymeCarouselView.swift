//
//  KeymeCarouselView.swift
//  Features
//
//  Created by 고도현 on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

import SwiftUI

struct KeymeCarouselView<Content: View>: View {
    typealias pageIndex = Int
    
    let pageCount: Int
    let visibleEdgeSpace: CGFloat
    let spacing: CGFloat
    let content: (pageIndex) -> Content
    
    @GestureState var dragOffset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    init(
        pageCount: Int,
        visibleEdgeSpace: CGFloat,
        spacing: CGFloat,
        @ViewBuilder content: @escaping (pageIndex) -> Content
    ) {
        self.pageCount = pageCount
        self.visibleEdgeSpace = visibleEdgeSpace
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { proxy in
            let baseOffset: CGFloat = spacing + visibleEdgeSpace
            let pageWidth: CGFloat = proxy.size.width - (visibleEdgeSpace + spacing) * 2
            let offsetX: CGFloat = baseOffset + CGFloat(currentIndex) * -pageWidth + CGFloat(currentIndex) * -spacing + dragOffset
            
            HStack(spacing: spacing) {
                ForEach(0..<pageCount, id: \.self) { pageIndex in
                    self.content(pageIndex)
                        .frame(
                            width: pageWidth,
                            height: proxy.size.height
                        )
                }
                .contentShape(Rectangle())
            }
            .offset(x: offsetX)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, out, _ in
                        out = value.translation.width
                    }
                    .onEnded { value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / pageWidth
                        let increment = Int(progress.rounded())
                        
                        currentIndex = max(min(currentIndex + increment, pageCount - 1), 0)
                    }
            )
        }
    }
}
