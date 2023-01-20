//
//  BannerAdView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/19.
//

import SwiftUI
import GoogleMobileAds

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
    
    

    var body: some View {
        Group {
            if InAppPurchaseModel.isSubscribe == false {
                ZStack {
                    GoogleAdBannerView(bannerView: bannerView)
                        .frame(width: bannerSize.width, height: bannerSize.height, alignment: .center)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 4)
                        }
                        .cornerRadius(5)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            MultiColorAnimeTextView(texts: [Text("Ad")],
                                                    fonts: [.system(size: 12)],
                                                    forgroundColors: [.white],
                                                    backgroudColors: [.red,.orange,.yellow,.green,.blue,.purple],
                                                    millisecond: 500)
                            .padding(.leading, -bannerSize.width / 2)
                            Spacer()
                        }
                        .padding(.top, -bannerSize.height / 2)
                        Spacer()
                    }
                    
                }
            }
        }
    }
}

