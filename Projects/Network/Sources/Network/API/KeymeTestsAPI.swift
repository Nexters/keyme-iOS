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
    case result(Int)
    case register(String)
}

extension KeymeTestsAPI: BaseAPI {
    public var path: String {
        switch self {
        case .onboarding:
            return "tests/onboarding"
        case .daily:
            return "tests/daily"
        case let .result(testResultId):
            return "tests/result/\(testResultId)"
        case .register:
            return "tests/result/register"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .register:
            return .post
        default:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .register(let resultCode):
            return .requestParameters(parameters: ["resultCode": resultCode], encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        // TODO: token 받아서 넣기
        return ["Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhY2Nlc3NUb2tlbiIsImlhdCI6MTY5MTg0MjM1NiwiZXhwIjoxNjk0NDM0MzU2LCJtZW1iZXJJZCI6Miwicm9sZSI6IlJPTEVfVVNFUiJ9.bLUl_ObvXr2pkLGNBZYWbJgLZLo3P0xB2pawckRGYZM"]
    }
    
    public var sampleData: Data {
        switch self {
        case .onboarding, .daily:
            return
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
        case .result:
            return
        """
        {
            "code": 200,
            "message": "요청에 성공했습니다.",
            "data": {
                "testResultId": 391,
                "testId": 4,
                "matchRate": 0.0,
                "results": [
                    {
                        "questionId": 36,
                        "title": "님은 거지방에서도 살아남을 사람이다",
                        "keyword": "절약왕",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/money.png",
                            "name": "MONEY",
                            "color": "568049"
                        },
                        "score": 1
                    },
                    {
                        "questionId": 37,
                        "title": "님은 술자리에서 가장 늦게 일어나는 타입이다",
                        "keyword": "술고래",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/passion.png",
                            "name": "PASSION",
                            "color": "F37952"
                        },
                        "score": 2
                    },
                    {
                        "questionId": 38,
                        "title": "님은 별별 TMI를 다 아는 인간 나무위키다",
                        "keyword": "인간나무위키",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/intelligence.png",
                            "name": "INTELLIGENCE",
                            "color": "D6EC63"
                        },
                        "score": 3
                    },
                    {
                        "questionId": 39,
                        "title": "님은 친구들 사이에서 개그맨이다",
                        "keyword": "개그맨",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/humor.png",
                            "name": "HUMOR",
                            "color": "643FFF"
                        },
                        "score": 4
                    },
                    {
                        "questionId": 40,
                        "title": "님은 걸어다니는 종합병원이다",
                        "keyword": "개복치",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/body.png",
                            "name": "BODY",
                            "color": "EEAFB1"
                        },
                        "score": 5
                    },
                    {
                        "questionId": 41,
                        "title": "님은 밥은 살려고 먹는다",
                        "keyword": "소식좌",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/food.png",
                            "name": "FOOD",
                            "color": "A74850"
                        },
                        "score": 5
                    },
                    {
                        "questionId": 42,
                        "title": "님은 주변의 변화를 빠르게 알아차리는 편이다",
                        "keyword": "눈썰미",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/sense.png",
                            "name": "SENSE",
                            "color": "A9DBC3"
                        },
                        "score": 3
                    },
                    {
                        "questionId": 43,
                        "title": "님은 하고 싶은 것이 생기면 바로 실행에 옮긴다",
                        "keyword": "진행시켜",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/planning.png",
                            "name": "PLANNING",
                            "color": "BF36FE"
                        },
                        "score": 4
                    },
                    {
                        "questionId": 44,
                        "title": "님은 맑은 햇살의 낮보다는 새벽 감성을 더 좋아한다",
                        "keyword": "새벽감성",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/sensibility.png",
                            "name": "SENSIBILITY",
                            "color": "89B5F6"
                        },
                        "score": 3
                    },
                    {
                        "questionId": 45,
                        "title": "님은 어떠한 것이든 솔직하게 표현하는 편이다",
                        "keyword": "돌직구",
                        "category": {
                            "iconUrl": "https://keyme-ec2-access-s3.s3.ap-northeast-2.amazonaws.com/icon/relationships.png",
                            "name": "RELATIONSHIPS",
                            "color": "905CFF"
                        },
                        "score": 4
                    }
                ]
            }
        }
        """
                .data(using: .utf8)!
        case .register:
            return
        """
        {
            "code": 200,
            "message": "요청에 성공했습니다.",
            "data": null
        }
        """
                .data(using: .utf8)!
        default:
            return Data()
        }
    }
}
