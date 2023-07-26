//
//  Script.swift
//  EnvPlugin
//
//  Created by 김영인 on 2023/07/26.
//

import ProjectDescription

public extension Project {
    static let script: [ProjectDescription.TargetScript] = [
        .pre(
            path: .relativeToRoot("Scripts/lint.sh"),
            name: "Lint codes",
            basedOnDependencyAnalysis: false,
            runForInstallBuildsOnly: true),
        .post(path: .relativeToRoot("Scripts/encrypt.sh"),
              name: "Encrypt the secret files")
    ]
}
