//
//  WebView.swift
//  reed
//
//  Created by Lukas Fülling on 22.12.20.
//

import Foundation
import SwiftUI
import WebKit
import Combine

struct WebView: NSViewRepresentable {
    
    public typealias NSViewType = WKWebView
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    public func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView {
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.customUserAgent = "Reed / 1.0"
        return webView
    }
    
    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<WebView>) {
        
    }
    
    private let webView: WKWebView = WKWebView()
    
    public func load() {
        webView.load(URLRequest(url: self.url))
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        
        var parent: WebView
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated  {
                if let url = navigationAction.request.url {
                    if NSWorkspace.shared.open(url) {
                        print("Link opened.")
                    }
                    decisionHandler(.cancel)
                } else {
                    print("Error opening link.")
                    decisionHandler(.allow)
                }
            } else {
                decisionHandler(.allow)
            }
            
        }
        
        public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

struct BrowserView: View {
    
    private let browser: WebView
    var url: String
    
    init(url: String) {
        self.url = url
        self.browser = WebView(url: URL(string: url)!)
    }
    
    var body: some View {
        HStack {
            browser
                .onAppear() {
                    self.browser.load()
                }
        }
        .padding()
    }
}
