//
//  KNativeAdView.swift
//  GaweeBaweeBoh
//
//  Created by 서창열 on 2023/08/02.
//

import Foundation
import UIKit
import GoogleMobileAds

class UnifiedNativeAdView : GoogleMobileAds.NativeAdView {
    init(ad:NativeAd, frame:CGRect) {
        super.init(frame: frame)
        loadXib()
        nativeAd = ad
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        abort()
    }
    
    private func loadXib() {
        let identifier = String(describing: type(of: self))
        let nibs = Bundle.main.loadNibNamed(identifier, owner: self, options: nil)
        
        guard let customView = nibs?.first as? UIView else { return }
        customView.frame = self.bounds
        self.addSubview(customView)
    }
    
    func initUI() {
        
        (iconView as! UIImageView).image = nativeAd?.icon?.image
        (headlineView as! UILabel).text = nativeAd?.headline
        (advertiserView as! UILabel).text = nativeAd?.advertiser
        (bodyView as! UILabel).text = nativeAd?.body
        (storeView as! UILabel).text = nativeAd?.store
        (priceView as! UILabel).text = nativeAd?.price
        mediaView?.mediaContent = nativeAd?.mediaContent
        nativeAd?.delegate = self
        mediaView?.layer.borderWidth = 2
        mediaView?.layer.borderColor = UIColor.systemTeal.cgColor
    }
    
    
}

extension UnifiedNativeAdView : NativeAdDelegate {
    public func nativeAdIsMuted(_ nativeAd: NativeAd) {
        print("NAdDelegate \(#function) \(#line)")
    }
    public func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        print("NAdDelegate \(#function) \(#line)")
    }
    public func nativeAdDidDismissScreen(_ nativeAd: NativeAd) {
        print("NAdDelegate \(#function) \(#line)")
    }
    public func nativeAdWillDismissScreen(_ nativeAd: NativeAd) {
        print("NAdDelegate \(#function) \(#line)")
    }
    public func nativeAdWillPresentScreen(_ nativeAd: NativeAd) {
        print("NAdDelegate \(#function) \(#line)")
    }
    public func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        print("NAdDelegate \(#function) \(#line)")
    }
    public func nativeAdDidRecordSwipeGestureClick(_ nativeAd: NativeAd) {
        print("NAdDelegate \(#function) \(#line)")
    }
}

extension UnifiedNativeAdView : NativeAdUnconfirmedClickDelegate {
    public func nativeAd(_ nativeAd: NativeAd, didReceiveUnconfirmedClickOnAssetID assetID: GADNativeAssetIdentifier) {
        print("NAdDelegate \(#function) \(#line)")

    }
    
    public func nativeAdDidCancelUnconfirmedClick(_ nativeAd: NativeAd) {
        print("NAdDelegate \(#function) \(#line)")

    }
    
    
}
