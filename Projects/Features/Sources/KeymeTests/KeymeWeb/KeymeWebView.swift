//
//  KeymeWebView.swift
//  Features
//
//  Created by 김영인 on 2023/08/17.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import WebKit

public struct KeymeWebView: UIViewRepresentable {
    public let url: String
    
    init(url: String) {
        self.url = url
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: CGRect.zero, configuration:  WKWebViewConfiguration())
        webView.backgroundColor = .init(white: 1, alpha: 0.3)
        
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {

    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    public class Coordinator: NSObject {
        let parent: KeymeWebView
        
        init(parent: KeymeWebView) {
            self.parent = parent
        }
    }
}
