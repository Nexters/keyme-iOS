//
//  DynamicText.swift
//  DSKit
//
//  Created by Young Bin on 2023/08/15.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public extension Text {
    static func keyme(_ text: String, font: Font.App) -> Text {
        Text(text)
            .font(font.value)
            .kerning(font.size * (font.kerning / 100))
    }
}
