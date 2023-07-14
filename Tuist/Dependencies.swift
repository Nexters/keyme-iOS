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
          .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "10.11.0"))
      ],
       platforms: [.iOS]
)
