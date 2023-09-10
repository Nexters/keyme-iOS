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
    private var completion: ((Error?) -> Void)?
    
    public func save(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
        self.completion = completion
    }

    @objc private func saveError(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        DispatchQueue.main.async {
            if let error {
                self.completion?(error)
            } else {
                self.completion?(nil)
            }
        }
    }
}
