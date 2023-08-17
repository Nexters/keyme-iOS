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

public struct SegmentControlView<SegmentType: Identifiable, Content: View>: View {
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
        }
        .padding(4)

        .background {
            BackgroundBlurringView(style: .systemChromeMaterialDark)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.hex("232323"), lineWidth: 1)
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
                    withAnimation(Animation.customInteractiveSpring()) {
                        selectedId = id
                    }
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
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(bgColor)
                    .matchedGeometryEffect(id: "SelectedTab", in: namespace)
            }
        }
    }
}

public enum Segment: Identifiable, CaseIterable {
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
