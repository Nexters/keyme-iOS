//
//  CircleGeometryAnimatable.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/08/06.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public protocol GeometryAnimatableCircle {
    var animationId: Int { get }
}

public extension GeometryAnimatableCircle {
    var innerCircleEffectID: String {
        "\(animationId) innerCircle"
    }
    
    var outlineEffectID: String {
        "\(animationId) outline"
    }
    
    var contentEffectID: String {
        "\(animationId) content"
    }
    
    var contentIconEffectID: String {
        "\(animationId) contentIcon"
    }
    
    var contentTextEffectID: String {
        "\(animationId) contentText"
    }
}
