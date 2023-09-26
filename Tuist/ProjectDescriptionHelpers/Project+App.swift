//
//  Project+App.swift
//  ProjectDescriptionHelpers
//
//  Created by 김영인 on 2023/07/25.
//

import ProjectDescription

import ConfigPlugin
import DependencyPlugin
import EnvPlugin

extension Project {
    public static func app(name: String,
                           internalDependencies: [TargetDependency] = [],
                           externalDependencies: [TargetDependency] = []
    ) -> Project {
        
        let mainTarget = Target(
            name: name,
            platform: Environment.platform,
            product: .app,
            bundleId: "\(Environment.organizationName).\(name)",
            deploymentTarget: Environment.deploymentTarget,
            infoPlist: .extendingDefault(with: Project.infoPlist),
            sources: ["Sources/**"],
            resources: [.glob(pattern: "Resources/**", excluding: [])],
            entitlements: .file(path: .relativeToRoot("Keyme.entitlements")),
            scripts: Project.lintScript + Project.encryptionScript,
            dependencies: internalDependencies + externalDependencies,
            settings: .settings(base: .baseSettings, configurations: XCConfig.project)
        )
        
        let testTarget = Target(
            name: "\(name)Tests",
            platform: Environment.platform,
            product: .unitTests,
            bundleId: "\(Environment.organizationName).\(name)Tests",
            infoPlist: .default,
            sources: ["Tests/Sources/**"],
            resources: [.glob(pattern: "Tests/Resources/**", excluding: [])],
            dependencies: [.target(name: name)],
            settings: .settings(base: .baseSettings, configurations: XCConfig.tests)
        )
        
        return Project(name: name,
                       organizationName: Environment.organizationName,
                       settings: .settings(configurations: XCConfig.project),
                       targets: [mainTarget, testTarget],
                       schemes: Project.appScheme)
    }
}
