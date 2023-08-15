//
//  CircleGeometryAnimatable.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/08/06.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Domain
import SwiftUI

protocol GeometryAnimatableCircle {
    var circleData: CircleData { get }
}

extension GeometryAnimatableCircle {
    var id: String {
        circleData.id.uuidString
    }
    
    var innerCircleEffectID: String {
        id + "innerCircle"
    }
    
    var outlineEffectID: String {
        id + "outline"
    }
    
    var contentEffectID: String {
        id + "content"
    }
}
