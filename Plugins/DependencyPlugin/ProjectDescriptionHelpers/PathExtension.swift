//
//  PathExtension.swift
//  DependencyPlugin
//
//  Created by 김영인 on 2023/07/25.
//

import ProjectDescription

public extension ProjectDescription.Path {
    static var keyme: Self {
        return .relativeToRoot("Projects/Keyme")
    }
    
    static var features: Self {
        return .relativeToRoot("Projects/Features")
    }
    
    static var domain: Self {
        return .relativeToRoot("Projects/Domain")
    }
    
    static var network: Self {
        return .relativeToRoot("Projects/Network")
    }
    
    static var core: Self {
        return .relativeToRoot("Projects/Core")
    }
    
    static func relativeToCore(_ path: String) -> Self {
        return .relativeToRoot("Projects/Core/\(path)")
    }
}
