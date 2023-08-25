//
//  KeymeAPI.swift
//  Network
//
//  Created by 김영인 on 2023/08/07.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import Moya

public enum KeymeAPI {
    case test
    case myPage(MyPage)
    case registerPushToken(String)
    case auth(Authorization)
    case registration(Registration)
    case member(Member)
}

extension KeymeAPI {
    public enum MyPage {
        case statistics(Int, RequestType)
        
        public enum RequestType: String {
            case similar = "SIMILAR"
            case different = "DIFFERENT"
        }
    }
    
    public enum Authorization {
        case signIn(oauthType: OauthType, accessToken: String)
        
        public enum OauthType: String {
            case kakao = "KAKAO"
            case apple = "APPLE"
        }
    }
    
    public enum Registration {
        case checkDuplicatedNickname(String)
        case uploadImage(Data)
        case updateMemberDetails(nickname: String, profileImage: String?, profileThumbnail: String?)
    }
    
    public enum Member {
        case fetch
    }
}

extension KeymeAPI: BaseAPI {
    public var path: String {
        switch self {
        case .test:
            return "/api"
            
        case .myPage(.statistics(let id, _)):
            return "/members/\(id)/statistics"
            
        case .auth(.signIn):
            return "/auth/login"
            
        case .registerPushToken:
            return "/members/devices"
            
        case .auth:
            return "/auth/login"
            
        case .registration(.checkDuplicatedNickname):
            return "members/verify-nickname"
            
        case .registration(.uploadImage):
            return "/images"
            
        case .registration(.updateMemberDetails):
            return "/members"
            
        case .member(.fetch):
            return "members"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .test, .myPage(.statistics), .member(.fetch):
            return .get
            
        case .auth(.signIn), .registerPushToken, .registration(.checkDuplicatedNickname), .registration(.uploadImage):
            return .post
            
        case .registration(.updateMemberDetails):
            return .patch
        }
    }
    
    public var task: Task {
        switch self {
        case .test:
            return .requestPlain
            
        case .myPage(.statistics(_, let type)):
            return .requestParameters(parameters: ["type": type.rawValue], encoding: URLEncoding.default)
            
        case .registerPushToken(let token):
            return .requestParameters(parameters: ["token": token], encoding: JSONEncoding.default)
            
        case .auth(.signIn(let oauthType, let accessToken)):
            return .requestParameters(
                parameters: [
                    "oauthType": oauthType.rawValue,
                    "token": accessToken
                ],
                encoding: JSONEncoding.prettyPrinted)
            
        case .registration(.checkDuplicatedNickname(let nickname)):
            return .requestJSONEncodable(nickname)
            
        case .registration(.uploadImage(let imageData)):
            let multipartFormData = MultipartFormData(
                provider: .data(imageData),
                name: "profile_image")
            
            return .uploadMultipart([multipartFormData])
        
        case .registration(.updateMemberDetails(let nickname, let profileImage, let profileThumbnail)):
            return .requestParameters(
                parameters: [
                    "nickname": nickname,
                    "profileImage": profileImage as Any,
                    "profileThumbnail": profileThumbnail as Any
                ],
                encoding: JSONEncoding.default)
            
        case .member(.fetch):
            return .requestPlain
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
    public var sampleData: Data {
        """
        {
            "id": 1,
            "name": "Test Item"
        }
        """
            .data(using: .utf8)!
    }
}
