//
//  Padding.swift
//  Core
//
//  Created by 김영인 on 2023/08/17.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public enum Padding {
    public static func insets(top: CGFloat=0, leading: CGFloat=0, bottom: CGFloat=0, trailing: CGFloat=0) -> EdgeInsets {
        return EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}
