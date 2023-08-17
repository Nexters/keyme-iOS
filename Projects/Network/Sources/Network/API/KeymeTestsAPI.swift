//
//  KeymeTestsAPI.swift
//  Network
//
//  Created by 김영인 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Moya

public enum KeymeTestsAPI {
    case onboarding
    case daily
}

extension KeymeTestsAPI: BaseAPI {
    public var path: String {
        switch self {
        case .onboarding:
            return "tests/onboarding"
        case .daily:
            return "tests/daily"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Moya.Task {
        return .requestPlain
    }
    
    public var headers: [String : String]? {
        // TODO: token 받아서 넣기
        return ["Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhY2Nlc3NUb2tlbiIsImlhdCI6MTY5MTg0MjM1NiwiZXhwIjoxNjk0NDM0MzU2LCJtZW1iZXJJZCI6Miwicm9sZSI6IlJPTEVfVVNFUiJ9.bLUl_ObvXr2pkLGNBZYWbJgLZLo3P0xB2pawckRGYZM"]
    }
    
    public var sampleData: Data {
        """
        {
            "code": 200,
            "message": "요청에 성공했습니다.",
            "data": {
                "testId": 4,
                "testResultId": null,
                "solvedCount": 0,
                "title": "님은 돈관리를 잘한다",
                "owner": {
                    "id": 2,
                    "nickname": "영인",
                    "profileThumbnail": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/keyme_default.png"
                },
                "questions": [
                    {
                        "questionId": 47,
                        "title": "님은 돈관리를 잘한다",
                        "keyword": "돈관리 마스터",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/money.png",
                            "name": "MONEY",
                            "color": "568049"
                        }
                    },
                    {
                        "questionId": 48,
                        "title": "님은 얘기를 하다가 갑자기 멍을 때린다",
                        "keyword": "무념무상",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/passion.png",
                            "name": "PASSION",
                            "color": "F37952"
                        }
                    },
                    {
                        "questionId": 49,
                        "title": "님은 길에서 도를 아십니까와 마주쳤을때 무시하고 지나간다",
                        "keyword": "마이웨이",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/passion.png",
                            "name": "PASSION",
                            "color": "F37952"
                        }
                    }
                ]
            }
        }
        """
            .data(using: .utf8)!
    }
}
