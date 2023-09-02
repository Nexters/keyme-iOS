//
//  InfoPlist.swift
//  Environment
//
//  Created by 김영인 on 2023/07/25.
//

import ProjectDescription

public extension Project {
    static let infoPlist: [String: InfoPlist.Value] =  [
        "CFBundleShortVersionString": "1.0",
        "CFBundleVersion": "1",
        "UIMainStoryboardFile": "",
        "UILaunchStoryboardName": "LaunchScreen",
        "CFBundleURLTypes": [
            [
                "CFBundleTypeRole": "Editor",
                "CFBundleURLSchemes": ["keyme"]
            ]
        ],
        "API_BASE_URL": "$(API_BASE_URL)",
        "UIUserInterfaceStyle": "Light",
        "NSAppTransportSecurity": [
            "NSExceptionDomains": [
                "api.keyme.space": [
                    "NSIncludesSubdomains": true,
                    "NSExceptionMinimumTLSVersion": "TLSv1.2",
                ],
            ]
        ],
        "LSApplicationQueriesSchemes": ["kakaokompassauth", "kakaolink"]
    ]
    
    static let baseUrlInfoPlist: [String: InfoPlist.Value] =  [
        "API_BASE_URL": "$(API_BASE_URL)",
    ]
}
