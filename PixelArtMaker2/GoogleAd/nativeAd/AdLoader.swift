//
//  AdLoader.swift
//  ShootingGame
//
//  Created by Changyeol Seo on 2023/07/27.
//

import Foundation
import GoogleMobileAds
#if DEBUG
fileprivate let adId = "ca-app-pub-3940256099942544/3986624511"
#else
fileprivate let adId = "ca-app-pub-7714069006629518/1614251100"
#endif

class AdLoader : NSObject {
    static let shared = AdLoader()
        
    var onError:(Error?)->Void = { _ in
                
    }
    
    private let adLoader:GADAdLoader
        
    private var nativeAds:[GADNativeAd] = []
    
    public var nativeAd:GADNativeAd? {
        if let ad = nativeAds.first {
            nativeAds.removeFirst()
            return ad
        }
        loadAd()
        return nil
    }
    
    public func getNativeAd(getAd:@escaping(_ ad:GADNativeAd)->Void) {
        if let ad = nativeAd {
            getAd(ad)
            return
        }
        loadAd()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {[weak self] in
            self?.getNativeAd(getAd: getAd)
        }
    }
    
    override init() {
        let option = GADMultipleAdsAdLoaderOptions()
        option.numberOfAds = 4
        adLoader = GADAdLoader(adUnitID: adId,
                                    rootViewController: UIApplication.shared.lastViewController,
                                    adTypes: [.native], options: [option])
        super.init()
        adLoader.delegate = self
        loadAd()
    }
    
    private func loadAd() {
        adLoader.load(.init())
    }
        
}

extension AdLoader : GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("\(#function) \(#line) nativeAdsCount : \(nativeAds.count)")
        nativeAds.append(nativeAd)
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print("\(#function) \(#line) nativeAdsCount : \(nativeAds.count)")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(#function) \(#line) \(error.localizedDescription)")
        self.onError(error)
    }

}

