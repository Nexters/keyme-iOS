import ProjectDescription

import ConfigPlugin
import DependencyPlugin
import EnvPlugin

public extension Project {
    static func makeModule(name: String,
                           internalDependencies: [TargetDependency] = [],
                           externalDependencies: [TargetDependency] = [],
                           isDynamicFramework: Bool = false,
                           hasTestTarget: Bool = true
    ) -> Project {
        var targets: [Target] = [ ]
        
        let target = Target(
            name: name,
            platform: Environment.platform,
            product: isDynamicFramework ? .framework : .staticFramework,
            bundleId: "\(Environment.organizationName).\(name)",
            deploymentTarget: Environment.deploymentTarget,
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: internalDependencies + externalDependencies,
            settings: .settings(base: .baseSettings, configurations: XCConfig.framework)

        )
        targets.append(target)
        
        if hasTestTarget {
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
            targets.append(testTarget)
        }
        
        return Project(name: name,
                       organizationName: Environment.organizationName,
                       settings: .settings(configurations: XCConfig.project),
                       targets: targets,
                       schemes: [Scheme.makeScheme(configs: "DEV", name: "\(name)"),
                                 Scheme.makeScheme(configs: "PROD", name: "\(name)")])
    }
}

extension Scheme {
    static func makeScheme(configs: ConfigurationName, name: String) -> Scheme {
        return Scheme(name: name,
                      buildAction: .buildAction(targets: ["\(name)"]),
                      testAction: .targets(["\(name)Tests"],
                                           configuration: configs,
                                           options: .options(coverage: true, codeCoverageTargets: ["\(name)"])),
                      runAction: .runAction(configuration: configs),
                      archiveAction: .archiveAction(configuration: configs),
                      profileAction: .profileAction(configuration: configs),
                      analyzeAction: .analyzeAction(configuration: configs)
        )
    }
}
