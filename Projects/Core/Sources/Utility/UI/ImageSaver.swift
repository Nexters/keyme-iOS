//
//  ImageSaver.swift
//  Core
//
//  Created by Young Bin on 2023/09/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import Photos

public class ImageSaver: NSObject {
    private let permissionError = NSError(
        domain: "ImageSaver",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "앨범에 접근할 수 없습니다."])
    
    public func save(_ image: UIImage) async throws -> String? {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        switch status {
        case .authorized:
            return try await self.saveImageToLibrary(image: image)
            
        default:
            throw permissionError
        }
    }
    
    private func saveImageToLibrary(image: UIImage) async throws -> String? {
        var assetIdentifier: String?
        
        try await PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            assetIdentifier = creationRequest.placeholderForCreatedAsset?.localIdentifier
        }
        
        return assetIdentifier
    }
}
