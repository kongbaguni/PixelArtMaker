//
//  BannerAdView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/19.
//

import SwiftUI
import GoogleMobileAds
import ActivityIndicatorView

struct BannerAdView: View {
    public enum SizeType {
        /** iPhone and iPod Touch ad size. Typically 320x50.*/
        case GADAdSizeBanner
        /** Taller version of GADAdSizeBanner. Typically 320x100.*/
        case GADAdSizeLargeBanner
        /** Medium Rectangle size for the iPad (especially in a UISplitView's left pane). Typically 300x250.*/
        case GADAdSizeMediumRectangle
        /** Full Banner size for the iPad (especially in a UIPopoverController or in UIModalPresentationFormSheet). Typically 468x60.*/
        case GADAdSizeFullBanner
        /** Leaderboard size for the iPad. Typically 728x90*/
        case GADAdSizeLeaderboard
        /** Skyscraper size for the iPad. Mediation only. AdMob/Google does not offer this size. Typically 120x600*/
        case GADAdSizeSkyscraper
    }
    let sizeType:SizeType
        
    private var bannerSize:CGSize {
        switch sizeType {
        case .GADAdSizeBanner:
            return .init(width: 320, height: 50)
        case .GADAdSizeLargeBanner:
            return .init(width: 320, height: 100)
        case .GADAdSizeMediumRectangle:
            return .init(width: 300, height: 250)
        case .GADAdSizeFullBanner:
            return .init(width: 468, height: 60)
        case .GADAdSizeLeaderboard:
            return .init(width: 728, height: 90)
        case .GADAdSizeSkyscraper:
            return .init(width: 120, height: 600)
        }
    }
    private var bannerView:GADBannerView {
        switch sizeType {
        case .GADAdSizeBanner:
            return GADBannerView(adSize : GADAdSizeBanner)
        case .GADAdSizeLargeBanner:
            return GADBannerView(adSize : GADAdSizeLargeBanner)
        case .GADAdSizeMediumRectangle:
            return GADBannerView(adSize : GADAdSizeMediumRectangle)
        case .GADAdSizeFullBanner:
            return GADBannerView(adSize : GADAdSizeFullBanner)
        case .GADAdSizeLeaderboard:
            return GADBannerView(adSize : GADAdSizeLeaderboard)
        case .GADAdSizeSkyscraper:
            return GADBannerView(adSize : GADAdSizeSkyscraper)
        }
    }
    
    @State var isLoading = true
    @State var error:Error? = nil

    var body: some View {
        Group {
            if InAppPurchaseModel.isSubscribe == false {
                ZStack {
                    if error == nil {
                        ActivityIndicatorView(isVisible: $isLoading, type: .default()).frame(width: 40, height: 40)
                        
                        GoogleAdBannerView(bannerView: bannerView, onError: { error in
                            self.error = error
                        })
                        .frame(width: bannerSize.width, height: bannerSize.height, alignment: .center)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5).stroke(Color.k_normalText, lineWidth: 4)
                        }
                        .cornerRadius(5)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                MultiColorAnimeTextView(texts: [Text("Ad")],
                                                        fonts: [.system(size: 8)],
                                                        forgroundColors: [.k_normalText],
                                                        backgroundColors: [.red,.orange,.yellow,.green,.blue,.purple,.red],
                                                        fps: 60 )
                                .padding(.leading, -bannerSize.width / 2 - 3)
                                Spacer()
                            }
                            .padding(.top, -bannerSize.height / 2 - 3)
                            Spacer()
                        }
                    }
                    
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .googleAdBannerDidReciveAdError)) { noti in
            error =  noti.object as? Error
        }
    }
}

