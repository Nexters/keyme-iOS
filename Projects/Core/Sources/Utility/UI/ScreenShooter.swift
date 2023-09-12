//
//  ScreenShooter.swift
//  Core
//
//  Created by Young Bin on 2023/09/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

public struct Screenshotter<Content: View>: UIViewControllerRepresentable {
    @Binding var isTakingScreenshot: Bool
    var onScreenshotTaken: (UIImage?) -> Void
    let content: () -> Content

    public init(
        isTakingScreenshot: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        onScreenshotTaken: @escaping (UIImage?) -> Void
    ) {
        self._isTakingScreenshot = isTakingScreenshot
        self.content = content
        self.onScreenshotTaken = onScreenshotTaken
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let hostingController = UIHostingController(rootView: content())
        
        viewController.addChild(hostingController)
        viewController.view.addSubview(hostingController.view)
        hostingController.view.frame = viewController.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        context.coordinator.hostingController = hostingController // coordinator에 hostingController를 저장합니다.
        return viewController
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.hostingController?.rootView = content() // rootView를 업데이트 합니다.

        if isTakingScreenshot {
            DispatchQueue.main.async {
                let screenshot = self.takeScreenshot(of: uiViewController.view)
                self.onScreenshotTaken(screenshot)
                self.isTakingScreenshot = false
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    public class Coordinator {
        var hostingController: UIHostingController<Content>?
    }

    func takeScreenshot(of view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        return snapshotImage
    }
}

// 아직 쓸 데는 없음
public extension View {
    func capture() -> UIImage? {
        let targetSize = UIScreen.main.bounds.size
        return capture(targetSize: targetSize)
    }
    
    func capture(targetSize: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        view?.layoutIfNeeded()  // Force layout

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
