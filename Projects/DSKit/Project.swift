//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 김영인 on 2023/08/12.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "DSKit",
    internalDependencies: [
        .Core
    ],
    hasResource: true,
    resourceSynthesizers: [
        .custom(name: "Lottie", parser: .json, extensions: ["lottie"]),
        .fonts(),
        .assets()
    ]
)
