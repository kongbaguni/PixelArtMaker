//
//  GoogleADViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AppTrackingTransparency

fileprivate let gaid = "ca-app-pub-3940256099942544/6978759866" // test ga id
//fileprivate let gaid = "ca-app-pub-7714069006629518/5985835565" // real ga id

class GoogleAd : NSObject {
    
    var interstitial:GADRewardedInterstitialAd? = nil
    
    private func loadAd(complete:@escaping(_ isSucess:Bool)->Void) {
        let request = GADRequest()
        
        ATTrackingManager.requestTrackingAuthorization { status in
            print("google ad tracking status : \(status)")
            GADRewardedInterstitialAd.load(withAdUnitID: gaid, request: request) { [weak self] ad, error in
                if let err = error {
                    print("google ad load error : \(err.localizedDescription)")
                }
                ad?.fullScreenContentDelegate = self
                self?.interstitial = ad
                complete(ad != nil)
            }
        }
    }
    
    var callback:(_ isSucess:Bool)->Void = { _ in}
    
    func showAd(complete:@escaping(_ isSucess:Bool)->Void) {
        if Date().timeIntervalSince1970 - (UserDefaults.standard.lastGoogleAdWatchTime?.timeIntervalSince1970 ?? 0) < 60 {
            complete(true)
            return
        }
        callback = complete
        loadAd { [weak self] isSucess in
            if isSucess == false {
                DispatchQueue.main.async {
                    complete(true)
                }
                return
            }
            if let vc = UIApplication.shared.keyWindow?.rootViewController {
                self?.interstitial?.present(fromRootViewController: vc, userDidEarnRewardHandler: {
                    
                })
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
            self.callback(true)
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
            self.callback(true)
        }
    }
}


