//
//  DismissKeyboardOnTap.swift
//  Core
//
//  Created by Young Bin on 2023/08/24.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public struct DismissKeyboardOnTap: ViewModifier {
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .gesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            )
    }
}
