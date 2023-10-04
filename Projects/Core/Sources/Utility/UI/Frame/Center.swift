//
//  Center.swift
//  Core
//
//  Created by 이영빈 on 10/3/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public extension View {
    func center() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                self
                Spacer()
            }
            Spacer()
        }
    }
}
