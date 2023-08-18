//
//  KeymeWebView.swift
//  Features
//
//  Created by 김영인 on 2023/08/17.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import WebKit

final class KeymeWebViewOption {
    var onCloseWebView: () -> Void
    var onTestSubmitted: (_ testResultId: Int) -> Void
    
    init(
        onCloseWebView: @escaping () -> Void = {},
        onTestSubmitted: @escaping (_ testResultId: Int) -> Void = { _ in }
    ) {
        self.onCloseWebView = onCloseWebView
        self.onTestSubmitted = onTestSubmitted
    }
}

public struct KeymeWebView: UIViewRepresentable {
    private let option: KeymeWebViewOption
    public let url: String
    
    init(url: String) {
        self.option = .init()
        self.url = url
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        
        // This is the important part
        webView.configuration.userContentController.add(context.coordinator, name: "appInterface")
        webView.backgroundColor = .init(white: 1, alpha: 0.3)
        webView.scrollView.isScrollEnabled = false
        
        if let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: encodedUrl) {
                webView.load(URLRequest(url: url))
            }
        }
        
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, option: option)
    }
    
    public class Coordinator: NSObject, WKScriptMessageHandler {
        let parent: KeymeWebView
        let option: KeymeWebViewOption
        
        init(parent: KeymeWebView, option: KeymeWebViewOption) {
            self.parent = parent
            self.option = option
        }
        
        public func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            if message.name == "appInterface",
               let messageBody = message.body as? [String: Any],
               let command = messageBody["command"] as? String {
                
                switch command {
                case "CLOSE_WEBVIEW":
                    option.onCloseWebView()
                    
                case "SEND_TEST_RESULT":
                    if let testResultId = messageBody["data"] as? Int {
                        option.onTestSubmitted(testResultId)
                    }
                    
                default:
                    print("Unknown command: \(command)")
                }
                
                print("Received message from the web: \(message.body)")
            }
        }
    }
}

public extension KeymeWebView {
    func onCloseWebView(_ handler: @escaping () -> Void) -> Self {
        self.option.onCloseWebView = handler
        return self
    }
    
    func onTestSubmitted(_ handler: @escaping (_ testResultId: Int) -> Void) -> Self {
        self.option.onTestSubmitted = handler
        return self
    }
}
