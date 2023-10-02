//
//  ExportPreviewView.swift
//  Features
//
//  Created by 이영빈 on 9/28/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Core
import DSKit
import SwiftUI

struct MypageImageExportPreviewView: View {
    @State var imageToShare: ScreenImage?
    @State var showAlert: Bool = false
    
    let image: ScreenImage
    let onDismissButtonTapped: () -> Void
    
    private let imageSaver = ImageSaver()
    typealias DSImage = DSKitAsset.Image

    var body: some View {
        ZStack(alignment: .center) {
            backgroundView.ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 32) {
                HStack {
                    closeButton(action: onDismissButtonTapped)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                                
                mainImageView
                    .padding(.horizontal, 33)

                actionButtonsView
                    .padding(.horizontal, 33)
                    .padding(.vertical, 22)
            }
        }
        .sheet(item: $imageToShare) { image in
            ActivityViewController(
                isPresented: Binding<Bool>(
                    get: { imageToShare != nil },
                    set: { if !$0 { imageToShare = nil } }),
                activityItems: [image.image])
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("이미지 저장 중 오류가 발생했어요"),
                message: Text("잠시후 다시 시도해주세요"),
                dismissButton: .default(Text("Ok"))
            )
        }
    }
    
    private var backgroundView: some View {
        DSKitAsset.Color.keymeBlack.swiftUIColor
    }
    
    private var mainImageView: some View {
        Image(uiImage: image.image)
            .resizable()
            .scaledToFit()
            .cornerRadius(24)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.3))
            }
    }
    
    private func closeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 24, height: 24)
                .scaledToFit()
                .foregroundColor(.white)
        }
    }
    
    private var actionButtonsView: some View {
        let buttons: [ExportButton] = [
            ExportButton(image: DSImage.gallery.swiftUIImage, text: "저장", action: saveToAlbum),
            ExportButton(image: DSImage.insta.swiftUIImage, text: "Instagram", action: postToInstagram),
            ExportButton(image: DSImage.instaStory.swiftUIImage, text: "스토리", action: shareToInstagramStory),
            ExportButton(image: DSImage.link.swiftUIImage, text: "Share", action: shareImageFile)
        ]
        
        return HStack(spacing: 10) {
            ForEach(buttons) { button in
                commonShapedButton(button, width: .infinity, height: 79)
            }
        }
    }
    
    private func shareToInstagramStory() {
        let image = image.image
        
        guard let storiesUrl = URL(string: "instagram-stories://share?source_application=969563760790586") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(storiesUrl) {
            guard let imageData = image.pngData() else { return }
            
            let pasteboardItems: [String: Any] = [
                "com.instagram.sharedSticker.stickerImage": imageData,
                "com.instagram.sharedSticker.backgroundTopColor": "#171717",
                "com.instagram.sharedSticker.backgroundBottomColor": "#171717"
            ]
            
            let pasteboardOptions = [
                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
            ]
            
            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
            UIApplication.shared.open(storiesUrl)
        } else {
            print("Sorry the application is not installed")
        }
    }
    
    private func postToInstagram() {
        Task {
            do {
                guard let localIdentifier = try await imageSaver.save(image.image) else {
                    showAlert = true
                    return
                }
                
                let urlString = "instagram://library?LocalIdentifier=\(localIdentifier)"
                
                guard
                    let url = URL(string: urlString),
                    await UIApplication.shared.canOpenURL(url)
                else {
                    return
                }
                
                await UIApplication.shared.open(url)
            } catch {
                showAlert = true
            }
        }
    }
    
    private func shareImageFile() {
        imageToShare = image
    }
    
    private func saveToAlbum() {
        Task {
            do {
                _ = try await imageSaver.save(image.image)
            } catch {
                showAlert = true
            }
        }
    }
}

private extension MypageImageExportPreviewView {
    struct ExportButton: Identifiable {
        var id: String { text }
        let image: Image
        let text: String
        let action: () -> Void
    }
    
    func commonShapedButton(_ data: ExportButton, width: CGFloat, height: CGFloat) -> some View {
        Button(action: data.action) {
            VStack(spacing: 9) {
                data.image
                
                Text.keyme(data.text, font: .body5)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: width)
            .frame(height: height)
            .background {
                Color.white.opacity(0.05)
            }
            .cornerRadius(14)
        }
    }
}
