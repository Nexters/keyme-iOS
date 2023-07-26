//
//  Environment.swift
//  Environment
//
//  Created by 이영빈 on 2023/07/13.
//

import ProjectDescription

public struct Environment {
    public static let appName = "Keyme"
    public static let organizationName = "team.humanwave"
    public static let deploymentTarget = DeploymentTarget.iOS(targetVersion: "16.0", devices: [.iphone])
    public static let platform = Platform.iOS
}
