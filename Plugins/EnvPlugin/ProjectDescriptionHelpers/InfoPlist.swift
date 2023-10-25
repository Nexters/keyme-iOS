//
//  InfoPlist.swift
//  Environment
//
//  Created by 김영인 on 2023/07/25.
//

import ProjectDescription

public extension Project {
    static let infoPlist: [String: InfoPlist.Value] =  [
        "CFBundleShortVersionString": "1.0.2",
        "CFBundleVersion": "1",
        "UIMainStoryboardFile": "",
        "UILaunchStoryboardName": "LaunchScreen",
        "CFBundleURLTypes": [
            [
                "CFBundleTypeRole": "Editor",
                "CFBundleURLSchemes": [
                    "keyme",
                    "kakao$(KAKAO_API_KEY)"
                ]
            ]
        ],
        "API_BASE_URL": "$(API_BASE_URL)",
        "KAKAO_API_KEY": "$(KAKAO_API_KEY)",
        "BITLY_API_KEY": "$(BITLY_API_KEY)",
        "UIUserInterfaceStyle": "Light",
        "NSAppTransportSecurity": [
            "NSExceptionDomains": [
                "api.keyme.space": [
                    "NSIncludesSubdomains": true,
                    "NSExceptionMinimumTLSVersion": "TLSv1.2",
                ],
            ]
        ],
        "LSApplicationQueriesSchemes": [
            "kakaokompassauth",
            "kakaolink",
            "instagram",
            "instagram-stories"
        ],
        "NSPhotoLibraryUsageDescription": "스크린샷을 저장하기 위해서 앨범 접근 권한이 필요합니다",
        "FirebaseAppDelegateProxyEnabled": false
    ]
    
    static let baseUrlInfoPlist: [String: InfoPlist.Value] =  [
        "API_BASE_URL": "$(API_BASE_URL)",
    ]
}
