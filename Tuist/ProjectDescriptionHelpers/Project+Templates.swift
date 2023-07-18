import ProjectDescription
import Environment

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
    /// Helper function to create the Project for this ExampleApp
    public static func app(name: String, platform: Platform, additionalTargets: [String]) -> Project {
        var dependencies = additionalTargets.map { TargetDependency.target(name: $0) }
        dependencies += [
            .external(name: "FirebaseMessaging")
        ]
        
        var targets = makeAppTargets(
            name: name,
            platform: platform,
            dependencies: dependencies)
        
        targets += additionalTargets.flatMap({ makeFrameworkTargets(name: $0, platform: platform) })
        return Project(name: name,
                       organizationName: Environment.organizationName,
                       targets: targets)
    }

    // MARK: - Private

    /// Helper function to create a framework target and an associated unit test target
    private static func makeFrameworkTargets(name: String, platform: Platform) -> [Target] {
        let sources = Target(
            name: name,
            platform: platform,
            product: .framework,
            bundleId: "\(Environment.organizationName).\(name)",
            deploymentTarget: .iOS(targetVersion: Environment.targetVersion, devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/\(name)/Sources/**"],
            resources: [],
            dependencies: [
                .external(name: "Moya"),
                .external(name: "CombineMoya")
            ])

        let tests = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "\(Environment.organizationName).\(name)Tests",
            deploymentTarget: .iOS(targetVersion: Environment.targetVersion, devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            resources: [],
            dependencies: [.target(name: name)])

        return [sources, tests]
    }

    /// Helper function to create the application target and the unit test target.
    private static func makeAppTargets(name: String, platform: Platform, dependencies: [TargetDependency]) -> [Target] {
        let platform: Platform = platform
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen",
            "CFBundleURLTypes": [
                [
                    "CFBundleTypeRole": "Editor",
                    "CFBundleURLSchemes": ["keyme"]
                ]
            ]
        ]

        let mainTarget = Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: "\(Environment.organizationName).\(name)",
            deploymentTarget: .iOS(targetVersion: "16.0", devices: .iphone),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/\(name)/Sources/**",],
            resources: [
                "Targets/\(name)/Resources/**"
            ],
            entitlements: .relativeToRoot("Keyme.entitlements"),
            scripts: [
                .pre(
                    path: .relativeToRoot("Scripts/lint.sh"),
                    name: "Lint codes",
                    basedOnDependencyAnalysis: false),
                .post(path: .relativeToRoot("Scripts/encrypt.sh"),
                      name: "Encrypt the secret files")
            ],
            dependencies: dependencies,
            settings: .settings(configurations: [
                .debug(name: "Debug", settings: [
                    "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]
                ]),
                .release(name: "Release", settings: [
                    "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]
                ])
            ]))
            
        let testTarget = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "\(Environment.organizationName).\(name)Tests",
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            dependencies: [
                .target(name: "\(name)")
        ])
        return [mainTarget, testTarget]
    }
}
