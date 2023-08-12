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

    struct Score {
        public static var checkResult: Font {
            return Font(DSKitFontFamily.Panchang.extrabold.font(size: 32))
        }

        public static var detailPage: Font {
            return Font(DSKitFontFamily.Panchang.extrabold.font(size: 32))
        }

        public static var mypage: Font {
            return Font(DSKitFontFamily.Panchang.extrabold.font(size: 32))
        }
    }
}
