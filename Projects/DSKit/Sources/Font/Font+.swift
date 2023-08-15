//
//  Font.swift
//  DSKit
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public extension Font {
    struct Keyme {
        public static var heading1: Font {
            return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 24))
        }

        public static var body1: Font {
            return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 20))
        }

        public static var body2: Font {
            return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 18))
        }

        public static var body3Semibold: Font {
            return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 16))
        }

        public static var body3Regular: Font {
            return Font(DSKitFontFamily.Pretendard.regular.font(size: 16))
        }

        public static var body4: Font {
            return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 14))
        }

        public static var body5: Font {
            return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 12))
        }

        public static var caption1: Font {
            return Font(DSKitFontFamily.Pretendard.medium.font(size: 12))
        }

        public static var toolTip: Font {
            return Font(DSKitFontFamily.Pretendard.regular.font(size: 12))
        }
    }
    
    enum Score {
        public static var checkResult: Font {
            return Font(DSKitFontFamily.Panchang.extrabold.font(size: 32))
        }

        public static var detailPage: Font {
            return Font(DSKitFontFamily.Panchang.extrabold.font(size: 40))
        }

        public static var mypage: Font {
            return Font(DSKitFontFamily.Panchang.extrabold.font(size: 18))
        }
    }
    
    enum App {
        case heading1
        case body1
        case body2
        case body3Semibold
        case body3Regular
        case body4
        case body5
        case caption1
        case toolTip
        case checkResult
        case detailPage
        case mypage
        
        var value: Font {
            switch self {
            case .heading1:
                return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 24))
            case .body1:
                return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 20))
            case .body2:
                return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 18))
            case .body3Semibold:
                return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 16))
            case .body3Regular:
                return Font(DSKitFontFamily.Pretendard.regular.font(size: 16))
            case .body4:
                return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 14))
            case .body5:
                return Font(DSKitFontFamily.Pretendard.semiBold.font(size: 12))
            case .caption1:
                return Font(DSKitFontFamily.Pretendard.medium.font(size: 12))
            case .toolTip:
                return Font(DSKitFontFamily.Pretendard.regular.font(size: 12))
            case .checkResult:
                return Font(DSKitFontFamily.Panchang.extrabold.font(size: 32))
            case .detailPage:
                return Font(DSKitFontFamily.Panchang.extrabold.font(size: 40))
            case .mypage:
                return Font(DSKitFontFamily.Panchang.extrabold.font(size: 18))
            }
        }
        
        var size: CGFloat {
            switch self {
            case .heading1:
                return 24
            case .body1:
                return 20
            case .body2:
                return 18
            case .body3Semibold, .body3Regular:
                return 16
            case .body4:
                return 14
            case .body5, .caption1, .toolTip:
                return 12
            case .checkResult:
                return 32
            case .detailPage:
                return 40
            case .mypage:
                return 18
            }
        }
        
        var kerning: CGFloat {
            // This is just an example. The actual kerning for each font style
            // will depend on your design specifications.
            switch self {
            case .heading1:
                return -5
            case .body1, .body2, .body3Semibold, .body3Regular, .body4, .body5, .toolTip:
                return -3
            case .caption1:
                return -2.5
            case .checkResult, .detailPage, .mypage:
                return 0
            }
        }
    }
}
