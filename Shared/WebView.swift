//
//  WebView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/07.
//

import SwiftUI
import WebKit
struct WebView: UIViewRepresentable {
    let url:URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
