//
//  Dependencies.swift
//  Config
//
//  Created by 이영빈 on 2023/07/14.
//

import Foundation

import ProjectDescription
let dependencies = Dependencies(
      swiftPackageManager: [
          .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "10.11.0")),
          .remote(url: "https://github.com/Moya/Moya", requirement: .upToNextMajor(from: "15.0.3"))
      ],
       platforms: [.iOS]
)
