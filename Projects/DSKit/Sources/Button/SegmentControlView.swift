//
//  SegmentControlView.swift
//  DSKit
//
//  Created by Young Bin on 2023/08/16.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import SwiftUIIntrospect
import Core

public struct SegmentControlView<SegmentType: Identifiable, Content: View>: View where SegmentType: Equatable {
    let segments: [SegmentType]
    @Binding var selected: SegmentType

    var titleNormalColor: Color = .white
    var titleSelectedColor: Color = .black
    
    let selectedBackgroundColor: Color = .white
    let viewBackgroundColor: Color = .hex("3c3c3c")

    @ViewBuilder var content: (SegmentType) -> Content
    
    @Namespace private var namespace

    public init(
        segments: [SegmentType],
        selected: Binding<SegmentType>,
        content: @escaping (SegmentType) -> Content
    ) {
        self.segments = segments
        self._selected = selected
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { bounds in
            HStack(alignment: .center, spacing: 0) {
                ForEach(segments) { segment in
                    SegmentButton(
                        id: segment,
                        selectedId: $selected,
                        titleNormalColor: titleNormalColor,
                        titleSelectedColor: titleSelectedColor,
                        bgColor: selectedBackgroundColor,
                        namespace: namespace
                    ) {
                        content(segment)
                    }
                    .frame(width: bounds.size.width / CGFloat(segments.count))
                }
            }
            .animation(Animation.customInteractiveSpring(), value: selected)
        }
        .padding(4)
        .background {
            BackgroundBlurringView(style: .systemChromeMaterialDark)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

extension SegmentControlView {
    struct SegmentButton<SegmentType: Identifiable, Content: View> : View {
        let id: SegmentType
        @Binding var selectedId: SegmentType
        
        var titleNormalColor: Color
        var titleSelectedColor: Color
        
        var bgColor: Color
        var namespace: Namespace.ID
        
        @ViewBuilder var content: () -> Content
        
        var body: some View {
            GeometryReader { bounds in
                Button(action: {
                    HapticManager.shared.tok()
                    selectedId = id
                }) {
                    content()
                }
                .frame(width: bounds.size.width, height: bounds.size.height)
            }
            .foregroundColor(selectedId.id == id.id ? titleSelectedColor : titleNormalColor)
            .background(buttonBackground)
        }
        
        @ViewBuilder private var buttonBackground: some View {
            if selectedId.id == id.id {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(bgColor)
                    .matchedGeometryEffect(id: "SelectedTab", in: namespace)
            }
        }
    }
}

public enum MyPageSegment: Identifiable, CaseIterable, Equatable {
    case similar, different
    
    public var id: String {
        title
    }
    
    public var title: String {
        switch self {
        case .similar:
            return "가장 비슷한"
        case .different:
            return "가장 차이나는"
        }
    }
}
