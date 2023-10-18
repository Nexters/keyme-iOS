//
//  BottomSheetWrapperView.swift
//  Features
//
//  Created by Young Bin on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Core

final class BottomSheetWrapperViewOption {
    var backgroundColor: Color
    var onDragChanged: (DragGesture.Value) -> Void
    var onDragEnded: (DragGesture.Value) -> Void
    
    init(
        backgroundColor: Color = .hex("232323"),
        onDragChanged: @escaping (DragGesture.Value) -> Void = { _ in },
        onDragEnded: @escaping (DragGesture.Value) -> Void = { _ in }
    ) {
        self.backgroundColor = backgroundColor
        self.onDragChanged = onDragChanged
        self.onDragEnded = onDragEnded
    }
}

struct BottomSheetWrapperView<Content: View>: View {
    let option: BottomSheetWrapperViewOption
    let content: Content
    
    init(
        option: BottomSheetWrapperViewOption = .init(),
        @ViewBuilder content: () -> Content
    ) {
        self.option = option
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            option.backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    grabber
                    Spacer()
                }
                .padding(.vertical)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged(option.onDragChanged)
                        .onEnded(option.onDragEnded))
                
                content
            }
            .fullFrame()
        }
        .zIndex(1)
    }
    
    private var grabber: some View {
        Capsule()
            .fill(.white.opacity(0.3))
            .frame(width: 40, height: 4)
    }
}

extension BottomSheetWrapperView {
    func onDragChanged(_ action: @escaping (DragGesture.Value) -> Void) -> BottomSheetWrapperView {
        option.onDragChanged = action
        return self
    }
    
    func onDragEnded(_ action: @escaping (DragGesture.Value) -> Void) -> BottomSheetWrapperView {
        option.onDragEnded = action
        return self
    }
    
    func backgroundColor(color: Color) -> BottomSheetWrapperView {
        option.backgroundColor = color
        return self
    }
}
