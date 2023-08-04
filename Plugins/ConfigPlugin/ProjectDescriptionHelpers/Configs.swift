//
//  Configs.swift
//  DependencyPlugin
//
//  Created by 김영인 on 2023/07/25.
//

import ProjectDescription

public struct XCConfig {
    private struct Path {
        static var tests: ProjectDescription.Path {
            .relativeToRoot("XCConfig/Target/Tests.xcconfig")
        }
        
        static var framework: ProjectDescription.Path {
            .relativeToRoot("XCConfig/Target/Framework.xcconfig")
        }
        
        static func project(_ config: String) -> ProjectDescription.Path { .relativeToRoot("XCConfig/App/\(config).xcconfig") }
    }
    
    public static let tests: [Configuration] = [
        .debug(name: "DEV", xcconfig: Path.tests),
        .release(name: "PROD", xcconfig: Path.tests),
    ]
    
    public static let framework: [Configuration] = [
        .debug(name: "DEV", xcconfig: Path.framework),
        .release(name: "PROD", xcconfig: Path.framework),
    ]
    
    public static let project: [Configuration] = [
        .debug(name: "DEV", xcconfig: Path.project("DEV")),
        .release(name: "PROD", xcconfig: Path.project("PROD")),
    ]
}
