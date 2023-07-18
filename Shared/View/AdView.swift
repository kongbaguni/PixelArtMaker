//
//  AdView.swift
//  GaweeBaweeBoh
//
//  Created by Changyeol Seo on 2023/07/11.
//

import SwiftUI
import GoogleMobileAds
import ActivityIndicatorView

#if DEBUG
fileprivate let adId = "ca-app-pub-3940256099942544/3986624511"
#else
fileprivate let adId = "ca-app-pub-7714069006629518/1614251100"
#endif

extension Notification.Name {
    static let googleAdNativeAdClick = Notification.Name("googleAdNativeAdClick_observer")
    static let googleAdPlayVideo = Notification.Name("googleAdPlayVideo_observer")
}

struct AdSubView : UIViewRepresentable {
    let receiveAd:(_ adinfo:GADNativeAd)->()
    func makeUIView(context: Context) -> some UIView {
        let view = AdLoaderView { adinfo in
            receiveAd(adinfo)
        }
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct AdView : View {
    @State var headline:String? = nil
    @State var bodyStr:String? = nil
    @State var adImage:Image? = nil
    @State var advertiser:String? = nil
    @State var callToAction:String? = nil
    @State var price:String? = nil
    @State var starRating:NSDecimalNumber? = nil
    @State var images:[UIImage] = []
    @State var store:String? = nil
    @State var isloading = true
    @State var isVideoAd = false
    @State var mediaContent:GADMediaContent? = nil
    @State var nativeAd:GADNativeAd? = nil
    var adWidth:CGFloat {
        switch UIDevice.current.orientation {
            case .landscapeRight, .landscapeLeft :
                return UIScreen.main.bounds.size.height - 20
            default:
                return UIScreen.main.bounds.size.width - 20
        }
    }
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ZStack {
                    AdSubView { [self] adinfo in
                        nativeAd = adinfo
                        if let uiimage = adinfo.icon?.image {
                            adImage = Image(uiImage: uiimage)
                        }
                        advertiser = adinfo.advertiser
                        callToAction = adinfo.callToAction
                        headline = adinfo.headline
                        bodyStr = adinfo.body
                        starRating = adinfo.starRating
                        price = adinfo.price
                        images = adinfo.images?.map({ image in
                            return image.image ?? UIImage()
                        }) ?? []
                        store = adinfo.store
                        isloading = false
                        isVideoAd = adinfo.mediaContent.hasVideoContent
                        mediaContent = adinfo.mediaContent
                    }
                    .opacity(0)
                    .frame(width: 10, height: 10)
                    
                    if let image = nativeAd?.images?.first {
                        if let uiimage = image.image {
                            Image(uiImage: uiimage)
                                .resizable()
                                .scaledToFill()
                                .blur(radius: 5)
                                .opacity(0.5)
                                .mask(Rectangle().frame(width: proxy.size.width, height: 100))
                        }
                    }
                    
                    ActivityIndicatorView(isVisible: $isloading, type: .default())
                        .frame(width: 40, height: 40)
                    VStack {
                        HStack {
                            ScrollView {
                                if let img = adImage {
                                    img.resizable().scaledToFit().frame(height: 80)
                                }
                                ForEach(images, id: \.self) { image in
                                    Image(uiImage: image).resizable().scaledToFit().frame(height: 80)
                                }
                            }
                            .padding(.trailing,5)
                            .frame(width:80,height: 80)
                            
                            ScrollView {
                                if let txt = headline {
                                    HStack {
                                        Text(txt).font(.headline).lineLimit(3)
                                        Spacer()
                                    }
                                }
                                if let txt = bodyStr {
                                    HStack {
                                        Text(txt).font(.caption).lineLimit(100)
                                        Spacer()
                                    }
                                }
                                if let txt = advertiser {
                                    HStack {
                                        Text(txt).font(.caption)
                                        Spacer()
                                    }
                                }
                                if let txt = store {
                                    HStack {
                                        Text(txt).font(.caption)
                                        Spacer()
                                    }
                                }
                                HStack {
                                    if let value = starRating {
                                        if(value.doubleValue > 0) {
                                            StarView(rating: value, color: .orange)
                                                .frame(width: 100)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            .frame(width: adWidth - 100, height:80)
                        }
                    }
                    .padding(10)
                    .shadow(color: .black, radius: 10, x: 5, y: 5)
                }
                .frame(width:proxy.size.width,height: 100)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(Color.k_normalText, lineWidth: 4)
                }
                VStack {
                    HStack {
                        MultiColorAnimeTextView(texts: [Text("Ad")],
                                                fonts: [.system(size: 12)],
                                                forgroundColors: [.white],
                                                backgroundColors: [.red,.orange,.yellow,.green,.blue,.purple,.red],
                                                fps: 60 )
                        Spacer()
                    }
                    Spacer()
                }
            }

        }
        .frame(height: 100)
        .background(Color.k_background)
    }
}

class AdLoaderView : GADMediaView {
    let loader:GADAdLoader
    let receiveAd:(_ adinfo:GADNativeAd)->()
    var pauseRequest = false
    init(receiveAd:@escaping(_ adinfo:GADNativeAd)->()) {
        
        self.receiveAd = receiveAd
        let option = GADMultipleAdsAdLoaderOptions()
        option.numberOfAds = 1
        self.loader = GADAdLoader(adUnitID: adId,
                                  rootViewController: UIApplication.topViewController,
                                  adTypes: [.native],
                                  options: [option])
        super.init(frame: .zero)
        
        self.loader.delegate = self
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] noti in
            self?.pauseRequest = true
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] noti in
            self?.pauseRequest = false
            self?.loadAd()
        }
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [weak self] noti in
            self?.layoutSubviews()
        }
        
        NotificationCenter.default.addObserver(forName: .googleAdPlayVideo, object: nil, queue: nil) { [weak self] noti in
            self?.mediaContent?.videoController.play()
        }
        self.autoresizingMask = [.flexibleWidth]
        loadAd()        
    }
    
    func loadAd() {
        guard pauseRequest == false else {
            return
        }
        loader.load(.init())
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) { [weak self] in
            self?.loadAd()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = UIScreen.main.bounds.size
        let shot = size.width < size.height ? size.width : size.height
        let long = size.width > size.height ? size.width : size.height
        switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                frame.size.width = long
            default:
                frame.size.width = shot
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AdLoaderView : GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        nativeAd.delegate = self
        nativeAd.enableCustomClickGestures()
        nativeAd.registerClickConfirmingView(self)
        nativeAd.recordCustomClickGesture()
        print("nativeAdDelegate : setDelegate \(nativeAd.isCustomClickGestureEnabled)")
        
        mediaContent = nativeAd.mediaContent
        receiveAd(nativeAd)
        if nativeAd.mediaContent.hasVideoContent {
            nativeAd.mediaContent.videoController.play()
            nativeAd.mediaContent.videoController.delegate = self
        }
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print(error.localizedDescription)
        
    }
    
}


extension AdLoaderView : GADNativeAdDelegate {
    func nativeAdIsMuted(_ nativeAd: GADNativeAd) {
        print("nativeAdDelegate : \(#function) \(#line)")
        print("nativeAdDelegate \(nativeAd.advertiser ?? "없다")")
        print("nativeAdDelegate \(nativeAd.advertiser ?? "없다")")
    }
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("nativeAdDelegate : \(#function) \(#line)")
        print("nativeAdDelegate \(nativeAd.advertiser ?? "없다")")
        if let advertiser = nativeAd.advertiser {
            if let url = URL(string: advertiser) {
                UIApplication.shared.open(url)
            }
        }
    }
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        print("nativeAdDelegate : \(#function) \(#line)")
    }
    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        print("nativeAdDelegate : \(#function) \(#line)")
    }
    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        print("nativeAdDelegate : \(#function) \(#line)")
    }
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        print("nativeAdDelegate : \(#function) \(#line)")
    }
    func nativeAdDidRecordSwipeGestureClick(_ nativeAd: GADNativeAd) {
        print("nativeAdDelegate : \(#function) \(#line)")
        print("nativeAdDelegate \(nativeAd.advertiser ?? "없다")")
    }
    
}

extension AdLoaderView : GADVideoControllerDelegate {
    func videoControllerDidMuteVideo(_ videoController: GADVideoController) {
        print("nativeAdDelegate : \(#function) \(#line)")
    }
    func videoControllerDidPlayVideo(_ videoController: GADVideoController) {
        print("nativeAdDelegate : \(#function) \(#line)")
    }
    func videoControllerDidPauseVideo(_ videoController: GADVideoController) {
        print("nativeAdDelegate : \(#function) \(#line)")
    }
    func videoControllerDidUnmuteVideo(_ videoController: GADVideoController) {
        print("nativeAdDelegate : \(#function) \(#line)")
    }
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
        print("nativeAdDelegate : \(#function) \(#line)")
    }
}
