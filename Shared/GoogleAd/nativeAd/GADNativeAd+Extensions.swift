//
//  GADNativeAd+Extensions.swift
//  GaweeBaweeBoh
//
//  Created by 서창열 on 2023/08/02.
//

import Foundation
import SwiftUI
import GoogleMobileAds

extension GADNativeAd {
    var view : some View {
        NadViewAdView(ad: self)
            .frame(height:350)
        
    }
}

fileprivate struct NadViewAdView : UIViewRepresentable {
    typealias UIViewType = UIView
    
    let ad:GADNativeAd
    
    func makeUIView(context: Context) -> UIView {
        let view = UnifiedNativeAdView(ad: ad, frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350))
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.frame.size.width = UIScreen.main.bounds.width
    }
}

