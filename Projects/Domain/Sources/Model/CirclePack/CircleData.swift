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
public extension CircleData {
    // MARK: - AppResult
    struct NetworkResult: Codable {
        let code: Int
        let data: ResponseData
    }
}

extension CircleData.NetworkResult {
    struct ResponseData: Codable {
        let memberId: Int
        let results: [ResultItem]
    }

    struct ResultItem: Codable {
        let questionStatistic: QuestionStatistic
        let coordinate: Coordinate
    }

    struct QuestionStatistic: Codable {
        let questionId: Int
        let title: String
        let keyword: String
        let category: Category
        let avgScore: Double
        let ownerScore: Double
    }

    struct Category: Codable {
        let iconUrl: String
        let name: String
        let color: String
    }

    struct Coordinate: Codable {
        let x: Double
        let y: Double
        let r: Double
    }
}

import Kingfisher

public extension CircleData.NetworkResult {
    func toCircleData() -> [CircleData] {
        return self.data.results.map { result -> CircleData in
            let coordinate = result.coordinate
            let questionStatistic = result.questionStatistic
            let category = questionStatistic.category
            
            let color = Color.hex(category.color)
            
            let metadata = CircleMetadata(
                questionId: questionStatistic.questionId,
                iconURL: URL(string: category.iconUrl),
                keyword: questionStatistic.keyword,
                averageScore: Float(questionStatistic.avgScore),
                myScore: Float(questionStatistic.ownerScore)
            )
            
            return CircleData(
                color: color,
                xPoint: CGFloat(coordinate.x),
                yPoint: CGFloat(coordinate.y),
                radius: CGFloat(coordinate.r),
                metadata: metadata
            )
        }
    }
}

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

public extension Array where Element == CircleData {
    func rotate(angle: Angle) -> [CircleData] {
        func formula(xPoint: CGFloat, yPoint: CGFloat) -> (x: CGFloat, y: CGFloat) {
            let degree = CGFloat(angle.radians)
            let newXPoint = xPoint * cos(degree) - yPoint * sin(degree)
            let newYPoint = yPoint * cos(degree) + xPoint * sin(degree)
            
            return (newXPoint, newYPoint)
        }
        
        return self.map { data in
            let newCoordinate = formula(xPoint: data.xPoint, yPoint: data.yPoint)
            let newCircle = CircleData(
                color: data.color,
                xPoint: newCoordinate.x,
                yPoint: newCoordinate.y,
                radius: data.radius,
                metadata: data.metadata)
            
            return newCircle
        }
    }
}
