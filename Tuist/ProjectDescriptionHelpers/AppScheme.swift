//
//  AppScheme.swift
//  ProjectDescriptionHelpers
//
//  Created by 김영인 on 2023/07/26.
//

import ProjectDescription

import EnvPlugin

extension Project {
    static let appScheme: [Scheme] = [
        .init(name: "\(Environment.appName)-DEV",
              buildAction: .buildAction(targets: ["\(Environment.appName)"]),
              runAction: .runAction(configuration: "DEV"),
              archiveAction: .archiveAction(configuration: "DEV"),
              profileAction: .profileAction(configuration: "DEV"),
              analyzeAction: .analyzeAction(configuration: "DEV")
             ),
        .init(name: "\(Environment.appName)-PROD",
              buildAction: .buildAction(targets: ["\(Environment.appName)"]),
              runAction: .runAction(configuration: "PROD"),
              archiveAction: .archiveAction(configuration: "PROD"),
              profileAction: .profileAction(configuration: "PROD"),
              analyzeAction: .analyzeAction(configuration: "PROD")
             )
    ]
}
