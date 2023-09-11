//
//  KeymeWebView.swift
//  Features
//
//  Created by 김영인 on 2023/08/17.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import WebKit

import Core
import Domain
import DSKit

final class SharedWebView {
    static let instance = WKWebView()
}

final class KeymeWebViewOption {
    var onCloseWebView: () -> Void
    var onTestSubmitted: (_ testResult: KeymeWebViewModel) -> Void
    
    init(
        onCloseWebView: @escaping () -> Void = {},
        onTestSubmitted: @escaping (_ testResult: KeymeWebViewModel) -> Void = { _ in }
    ) {
        self.onCloseWebView = onCloseWebView
        self.onTestSubmitted = onTestSubmitted
    }
}

public struct KeymeWebView: UIViewRepresentable {
    private var url: String?
    private let accessToken: String
    private let option: KeymeWebViewOption
    private let webView: WKWebView
    
    init(url: String?, accessToken: String) {
        self.url = url
//        self._url = url
        self.option = .init()
        self.accessToken = accessToken
        self.webView = SharedWebView.instance
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        // This is the important part
        webView.navigationDelegate = context.coordinator
        
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "appInterface")
        webView.configuration.userContentController.add(context.coordinator, name: "appInterface")

        webView.backgroundColor = UIColor(Color.hex("171717"))
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        
        let url = self.url ?? "about:blank"
        if
            let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encodedUrl)
        {
            var request = URLRequest(url: url)
            request.setValue(accessToken, forHTTPHeaderField: "Authorization")
            webView.customUserAgent = "KEYME_\(accessToken)"
            webView.load(request)
        }
        
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, option: option)
    }
    
    public final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        private let decoder = JSONDecoder()
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
            print("Received message from the web with name \(message.name): \(message.body)")
            
            if message.name == "appInterface",
               let messageBody = message.body as? [String: Any],
               let command = messageBody["command"] as? String {
                
                switch command {
                case "CLOSE_WEBVIEW":
                    option.onCloseWebView()
                    self.parent.load(url: "about:blank")
                    
                case "SEND_TEST_RESULT":
                    if let data = messageBody["data"] as? [String: Any] {
                        guard
                            let jsonData = try? JSONSerialization.data(withJSONObject: data),
                            let testResult = try? decoder.decode(KeymeWebViewModel.self, from: jsonData)
                        else {
                            print("Webview: Error while decoding")

                            return
                        }
                        
                        option.onTestSubmitted(testResult)
                    }
                    
                default:
                    print("Unknown command: \(command)")
                }
            }
        }
    }
}

public extension KeymeWebView {
    @discardableResult
    func load(url: String?) -> Self {
        guard let url = URL(string: url ?? "about:blank") else { return self }
        
        let request = URLRequest(url: url)
        self.webView.load(request)
        return self
    }
    
    func onCloseWebView(_ handler: @escaping () -> Void) -> Self {
        self.option.onCloseWebView = handler
        return self
    }
    
    func onTestSubmitted(_ handler: @escaping (_ testResult: KeymeWebViewModel) -> Void) -> Self {
        self.option.onTestSubmitted = handler
        return self
    }
}
