//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 김영인 on 2023/07/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Core",
    internalDependencies: [
        .Util,
        .ThirdPartyLib
    ],
    hasTestTarget: false
)
