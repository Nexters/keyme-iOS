//
//  CircleGeometryAnimatable.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/08/06.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public protocol GeometryAnimatableCircle {
    var id: String { get }
}

public extension GeometryAnimatableCircle {
    var innerCircleEffectID: String {
        id + "innerCircle"
    }
    
    var outlineEffectID: String {
        id + "outline"
    }
    
    var contentEffectID: String {
        id + "content"
    }
    
    var contentIconEffectID: String {
        id + "contentIcon"
    }
    
    var contentTextEffectID: String {
        id + "contentText"
    }
}
