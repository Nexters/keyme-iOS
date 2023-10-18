//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 김영인 on 2023/07/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "ThirdPartyLib",
    externalDependencies: [
        .Moya,
        .CombineMoya,
        .ComposableArchitecture,
        .Kingfisher,
        .KakaoSDK,
        .SwiftUIIntrospect,
        .Lottie
    ],
    isDynamicFramework: true,
    hasTestTarget: false
)
