//
//  WebView.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/2/23.
//

import SwiftUI
import WebKit
fileprivate class _WebViewNavigationDelete : NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
            
        if url.isFileURL {
            decisionHandler(.allow)
        } else {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        }
    }
}

fileprivate struct _WebView: UIViewRepresentable {
    let url:URL
    let allowBackForwardNavigationGesture:Bool
    let navigationDelegate = _WebViewNavigationDelete()
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = navigationDelegate
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.allowsBackForwardNavigationGestures = allowBackForwardNavigationGesture
        uiView.isOpaque = false
        uiView.backgroundColor = .clear
        uiView.scrollView.backgroundColor = .clear
    }
}

struct WebView : View {
    let url:URL
    let title:Text
    var body: some View {
        _WebView(url: url, allowBackForwardNavigationGesture: true)
            .navigationTitle(title)
    }
}
#Preview {
    WebView(url: URL(string: "https://google.com")!,
            title:.init("we bview"))
}
