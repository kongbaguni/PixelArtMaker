//
//  BannerAdView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/19.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: View {
    let bannerView = GADBannerView(adSize: GADAdSizeLargeBanner)

    var body: some View {
        Group {
            if InAppPurchaseModel.isSubscribe == false {
                GoogleAdBannerView(bannerView: bannerView)
                    .frame(width: 320, height: 100, alignment: .center)
                    .padding(.top,10)
                    .padding(.bottom,10)
            }
        }
    }
}

struct BannerAdView_Previews: PreviewProvider {
    static var previews: some View {
        BannerAdView()
    }
}
