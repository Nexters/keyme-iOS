//
//  SubmitResponseDTO.swift
//  Network
//
//  Created by YoungBin Lee on 10/23/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

public typealias TestResult = SubmitResponseDTO.TestResult
public struct SubmitResponseDTO: Decodable {
    let code: Int
    let message: String
    public let data: TestResult
    
    public struct TestResult: Decodable, Equatable {
        public let matchRate: Float
        public let resultCode: String?
        public let testResultId: Int
    }
}
