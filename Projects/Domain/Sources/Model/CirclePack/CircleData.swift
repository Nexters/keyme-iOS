//
//  CircleData.swift
//  Keyme
//
//  Created by Young Bin on 2023/07/25.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Core
import SwiftUI
import Foundation

public struct CircleData {
    public let isEmptyCircle: Bool
    
    public let color: Color
    public let xPoint: CGFloat
    public let yPoint: CGFloat
    public let radius: CGFloat
    
    public let metadata: CircleMetadata
    
    static public func emptyCircle(radius: CGFloat) -> CircleData {
        self.init(
            isEmptyCircle: true,
            color: .clear,
            xPoint: 0,
            yPoint: 0,
            radius: radius,
            metadata: CircleMetadata.emptyData)
    }
    
    public init(
        color: Color,
        xPoint: CGFloat,
        yPoint: CGFloat,
        radius: CGFloat,
        metadata: CircleMetadata
    ) {
        self.init(
            isEmptyCircle: false, color: color, xPoint: xPoint, yPoint: yPoint, radius: radius, metadata: metadata)
    }
    
    private init(
        isEmptyCircle: Bool,
        color: Color,
        xPoint: CGFloat,
        yPoint: CGFloat,
        radius: CGFloat,
        metadata: CircleMetadata
    ) {
        self.isEmptyCircle = isEmptyCircle
        self.color = color
        self.xPoint = xPoint
        self.yPoint = yPoint
        self.radius = radius
        self.metadata = metadata
    }
}

// 네트워크 데이터
//public extension CircleData {
//    // MARK: - AppResult
//    struct NetworkResult: Codable {
//        let data: DataField
//        
//        struct DataField: Codable {
//            let memberID: Int
//            let results: [Result]
//
//            enum CodingKeys: String, CodingKey {
//                case memberID = "memberId"
//                case results
//            }
//        }
//    }
//}
//
//extension CircleData.NetworkResult {
//    struct Result: Codable {
//        let questionStatistic: QuestionStatistic
//        let coordinate: Coordinate
//    }
//
//    struct Coordinate: Codable {
//        let x, y, r: Double
//    }
//
//    struct QuestionStatistic: Codable {
//        let questionID: Int
//        let title, keyword: String
//        let category: Category
//        let avgScore: Int
//
//        enum CodingKeys: String, CodingKey {
//            case questionID = "questionId"
//            case title, keyword, category, avgScore
//        }
//    }
//    
//    struct Category: Codable {
//        let iconURL: String
//        let name, color: String
//
//        enum CodingKeys: String, CodingKey {
//            case iconURL = "iconUrl"
//            case name, color
//        }
//    }
//}
//
//public extension CircleData.NetworkResult {
//    func toCircleData() -> [CircleData] {
//        return self.data.results.map { result -> CircleData in
//            let coordinate = result.coordinate
//            let questionStatistic = result.questionStatistic
//            let category = questionStatistic.category
//            
//            let color = Color.hex(category.color)
//            
//            let icon = Image(systemName: "person")
//            
//            let metadata = CircleMetadata(
//                icon: icon,
//                keyword: questionStatistic.keyword,
//                averageScore: Float(questionStatistic.avgScore),
//                myScore: 0
//            )
//            
//            return CircleData(
//                color: color,
//                xPoint: CGFloat(coordinate.x),
//                yPoint: CGFloat(coordinate.y),
//                radius: CGFloat(coordinate.r),
//                metadata: metadata
//            )
//        }
//    }
//}

extension CircleData: Equatable {
    public static func == (lhs: CircleData, rhs: CircleData) -> Bool {
        lhs.id == rhs.id
    }
}

extension CircleData: Identifiable {
    public var id: Int {
        metadata.animationId
    }
}
