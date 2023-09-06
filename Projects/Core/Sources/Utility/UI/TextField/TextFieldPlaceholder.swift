//
//  TextFieldPlaceholder.swift
//  Core
//
//  Created by 이영빈 on 2023/08/31.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
