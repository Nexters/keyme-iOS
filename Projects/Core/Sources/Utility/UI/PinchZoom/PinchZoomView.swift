//
//  PinchZoomView.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/07/26.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class PinchZoomView: UIView {
    weak var delegate: PinchZoomViewDelgate?

    private var lastScale: CGFloat = 1
    
    private(set) var scale: CGFloat = 0 {
        didSet {
            delegate?.pinchZoomView(self, didChangeScale: scale)
        }
    }

    private(set) var anchor: UnitPoint = .center {
        didSet {
            delegate?.pinchZoomView(self, didChangeAnchor: anchor)
        }
    }

    private(set) var offset: CGSize = .zero {
        didSet {
            delegate?.pinchZoomView(self, didChangeOffset: offset)
        }
    }

    private(set) var isPinching: Bool = false {
        didSet {
            delegate?.pinchZoomView(self, didChangePinching: isPinching)
        }
    }

    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0

    init() {
        super.init(frame: .zero)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc private func pinch(gesture: UIPinchGestureRecognizer) {

        switch gesture.state {
        case .began:
            isPinching = true
            startLocation = gesture.location(in: self)
            anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
            numberOfTouches = gesture.numberOfTouches

        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                // 사용 중인 손가락 수가 바뀔 경우 튀어버리지 않도록 시작 위치 조정
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                startLocation = CGPoint(
                    x: startLocation.x + jumpDifference.width,
                    y: startLocation.y + jumpDifference.height)

                numberOfTouches = gesture.numberOfTouches
            }

            scale = lastScale * gesture.scale

            location = gesture.location(in: self)
            offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
            
        case .ended, .cancelled, .failed:
            isPinching = false
            scale = scale.between(min: 0.5, max: 2.0)
            lastScale = scale
            anchor = .center
            offset = .zero
        default:
            break
        }
    }
}
