//
//  Dependency+Project.swift
//  DependencyPlugin
//
//  Created by 김영인 on 2023/07/25.
//

import ProjectDescription

public extension TargetDependency {
    static let Keyme = project(target: "Keyme", path: Path.keyme)
    
    static let Features = project(target: "Features", path: Path.features)
    
    static let Domain = project(target: "Domain", path: Path.domain)
    
    static let Network = project(target: "Network", path: Path.network)
    
    static let Core = project(target: "Core", path: Path.core)
    
    static let Util = project(target: "Util", path: Path.relativeToCore("Util"))
    
    static let ThirdPartyLib = project(target: "ThirdPartyLib", path: Path.relativeToCore("ThirdPartyLib"))
}
