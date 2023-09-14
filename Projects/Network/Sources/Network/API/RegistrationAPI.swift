//
//  RegistrationAPI.swift
//  Network
//
//  Created by 이영빈 on 2023/08/25.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import Moya

public enum RegistrationAPI {
    case checkDuplicatedNickname(String)
    case uploadImage(Data)
    case updateMemberDetails(nickname: String, profileImage: String?, profileThumbnail: String?)
}

extension RegistrationAPI: BaseAPI {
    public var path: String {
        switch self {
        case .checkDuplicatedNickname:
            return "members/verify-nickname"
        case .uploadImage:
            return "images"
        case .updateMemberDetails:
            return "members"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .checkDuplicatedNickname, .uploadImage:
            return .post
        case .updateMemberDetails:
            return .patch
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .checkDuplicatedNickname(let nickname):
            return .requestJSONEncodable(nickname)
            
        case .uploadImage(let imageData):
            let multipartData = MultipartFormData(
                provider: .data(imageData),
                name: "image",
                fileName: "image.jpeg",
                mimeType: "image/jpeg")

            return .uploadMultipart([multipartData])
        
        case .updateMemberDetails(let nickname, let profileImage, let profileThumbnail):
            return .requestParameters(
                parameters: [
                    "nickname": nickname,
                    "profileImage": profileImage as Any,
                    "profileThumbnail": profileThumbnail as Any
                ],
                encoding: JSONEncoding.default)
        }
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
