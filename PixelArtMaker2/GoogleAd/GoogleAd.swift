//
//  GoogleADViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency
#if DEBUG
fileprivate let interstitialVideoGaId = "ca-app-pub-3940256099942544/4411468910" // test ga id
fileprivate let bannerGaId = "ca-app-pub-3940256099942544/2934735716" // test ga id
#else
fileprivate let interstitialVideoGaId = "ca-app-pub-7714069006629518~8448347376" // real ga id
fileprivate let bannerGaId = "ca-app-pub-7714069006629518/3753098473" // real ga id
#endif

class GoogleAd : NSObject {
    
    var interstitial:GADInterstitialAd? = nil
    
    private func loadAd(complete:@escaping(_ error:Error?)->Void) {
        let request = GADRequest()
        
        ATTrackingManager.requestTrackingAuthorization { status in
            print("google ad tracking status : \(status)")
        
            GADInterstitialAd.load(withAdUnitID: interstitialVideoGaId, request: request) {[weak self] ad, error in
                ad?.fullScreenContentDelegate = self
                self?.interstitial = ad
                
                complete(error)
            }
        }
    }
    
    var callback:(_ error:Error?)->Void = { _ in}
    
    var requsetAd = false
    
    func showAd(complete:@escaping(_ error:Error?)->Void) {
        if InAppPurchaseModel.isSubscribe {
            complete(nil)
            return
        }
        if requsetAd {
            return
        }
        requsetAd = true
        callback = complete
        loadAd { [weak self] error in
            self?.requsetAd = false
            if error != nil {
                DispatchQueue.main.async {
                    complete(error)
                }
                return
            }
            if let vc = UIApplication.shared.lastViewController {
                self?.interstitial?.present(fromRootViewController: vc)
            }
        }
    }
     
    
}

extension GoogleAd : GADFullScreenContentDelegate {
    //광고 실패
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("google ad \(#function)")
        print(error.localizedDescription)
        DispatchQueue.main.async {
            self.callback(error)
        }
    }
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("google ad \(#function)")
    }
    //광고시작
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("google ad \(#function)")
    }
    //광고 종료
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("google ad \(#function)")
        UserDefaults.standard.lastGoogleAdWatchTime = Date()
        DispatchQueue.main.async {
            self.callback(nil)
        }
    }
}
 
extension Notification.Name {
    static let googleAdBannerDidReciveAdError = Notification.Name("googleAdBannerDidReciveAdError_observer")
}

struct GoogleAdBannerView: UIViewRepresentable {
    class BannerDelegate : NSObject, GADBannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("BannerDelegate \(#function) \(#line)")
        }
        func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
            print("BannerDelegate \(#function) \(#line)")
        }
        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
            print("BannerDelegate \(#function) \(#line)")
        }
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: any Error) {
            print("BannerDelegate \(#function) \(#line)")
            print(error.localizedDescription)
            NotificationCenter.default.post(name: .googleAdBannerDidReciveAdError, object: error)
        }
    }

    
    let bannerView:GADBannerView
    let onError:(Error?)->Void
    let delegate = BannerDelegate()
    
    func makeUIView(context: Context) -> GADBannerView {
        
        bannerView.adUnitID = bannerGaId
        bannerView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
        bannerView.delegate = self.delegate
        return bannerView
    }
  
  func updateUIView(_ uiView: GADBannerView, context: Context) {
      uiView.load(GADRequest())
  }
}


