//
//  GoogleADViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import GoogleMobileAds

//fileprivate let gaid = "ca-app-pub-7714069006629518/9980070837"
#if DEBUG
fileprivate let gaid = "ca-app-pub-3940256099942544/6978759866"

#else
fileprivate let gaid = "ca-app-pub-7714069006629518/5985835565"
#endif

class GoogleAd : NSObject {
    static let shared = GoogleAd()
    private var interstitial: GADRewardedInterstitialAd? = nil

    func loadAd() {
        let request = GADRequest()
        
        GADRewardedInterstitialAd.load(withAdUnitID: gaid, request: request) { [self] ad, error in
            if let err = error {
                print("google ad load error : \(err.localizedDescription)")
                return
            }
                
            if let ad = ad {
                ad.fullScreenContentDelegate = self
                interstitial = ad
            }
            else {
                print("ad 가 없다")
            }
        }
    }
    var callback:(_ isSucess:Bool)->Void = { _ in}
    
    func showAd(complete:@escaping(_ isSucess:Bool)->Void) {
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            print(interstitial == nil ? "없다" : "있다")
            interstitial?.present(fromRootViewController: vc, userDidEarnRewardHandler: {[self] in
                print(interstitial?.adMetadata ?? "메타 없다")
            })
            callback = complete
        }
    }
        
}

extension GoogleAd : GADFullScreenContentDelegate {
    //광고 실패
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("google ad \(#function)")
        print(error.localizedDescription)
        callback(true)
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
        callback(true)
        loadAd()
    }
}


