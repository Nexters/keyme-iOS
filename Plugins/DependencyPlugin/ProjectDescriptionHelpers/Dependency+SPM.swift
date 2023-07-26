//
//  Dependency+SPM.swift
//  DependencyPlugin
//
//  Created by 김영인 on 2023/07/25.
//

import ProjectDescription

public extension TargetDependency {
    static let FirebaseMessaging = TargetDependency.external(name: "FirebaseMessaging")
    static let Moya = TargetDependency.external(name: "Moya")
    static let CombineMoya = TargetDependency.external(name: "CombineMoya")
}
