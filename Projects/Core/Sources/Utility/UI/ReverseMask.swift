//
//  ReverseMask.swift
//  Core
//
//  Created by Young Bin on 2023/09/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public extension View {
    @inlinable func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask(
            ZStack(alignment: .center) {
                Rectangle()
                
                mask()
                    .blendMode(.destinationOut)
            }
                .compositingGroup()
        )
    }
}
