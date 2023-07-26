//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 김영인 on 2023/07/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

import EnvPlugin

let project = Project.app(
    name: Environment.appName,
    internalDependencies: [
        .Features,
        .Core
    ],
    externalDependencies: [
        .FirebaseMessaging
    ]
)
