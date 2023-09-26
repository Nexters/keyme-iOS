//
//  Dependencies.swift
//  Config
//
//  Created by 이영빈 on 2023/07/14.
//

import ProjectDescription
import ProjectDescriptionHelpers

import ConfigPlugin

let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies(
        [
            .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMinor(from: "10.11.0")),
            .remote(url: "https://github.com/Moya/Moya", requirement: .upToNextMinor(from: "15.0.3")),
            .remote(url: "https://github.com/pointfreeco/swift-composable-architecture", requirement: .upToNextMinor(from: "0.57.0")),
            .remote(url: "https://github.com/onevcat/Kingfisher", requirement: .upToNextMinor(from: "7.9.0")),
            .remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .upToNextMinor(from: "2.16.0")),
            .remote(url: "https://github.com/siteline/SwiftUI-Introspect", requirement: .upToNextMinor(from: "0.10.0")),
            .remote(url: "https://github.com/airbnb/lottie-ios", requirement: .upToNextMinor(from: "4.2.0"))
        ],
        baseSettings: .settings(configurations: XCConfig.framework)
    )
)
