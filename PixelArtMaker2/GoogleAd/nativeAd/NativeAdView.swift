//
//  AdView.swift
//  GaweeBaweeBoh
//
//  Created by Changyeol Seo on 2023/07/11.
//

import SwiftUI
import ActivityIndicatorView
import GoogleMobileAds

#if DEBUG
fileprivate let adId = "ca-app-pub-3940256099942544/3986624511"
#else
fileprivate let adId = "ca-app-pub-7714069006629518/1560510288"
#endif

extension Notification.Name {
    static let googleAdNativeAdClick = Notification.Name("googleAdNativeAdClick_observer")
    static let googleAdPlayVideo = Notification.Name("googleAdPlayVideo_observer")
}

struct NativeAdView : View {
    @State var loading = true
    @State var nativeAd:NativeAd? = nil
    @State var error:Error? = nil
    var body: some View {
        ZStack {
            if error == nil {
                if let view = nativeAd?.view {
                    view
                }
                VStack(alignment: .center) {
                    ActivityIndicatorView(isVisible: $loading, type: .default()).frame(width: 50, height: 50)
                }.frame(height:350)
            } 
        }.onAppear {
            loading = true
            AdLoader.shared.onError = { error in
                self.error = error
            }
            AdLoader.shared.getNativeAd(getAd: {[self] ad in
                nativeAd = ad
                loading = false
            })
        }
    }
}

