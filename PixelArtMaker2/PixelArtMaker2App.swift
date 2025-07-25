//
//  PixelArtMaker2App.swift
//  PixelArtMaker2
//
//  Created by Changyeol Seo on 4/23/24.
//

import SwiftUI
import RealmSwift
import GoogleMobileAds
import SwiftyStoreKit
import FirebaseAppCheck
import AppTrackingTransparency
import UserMessagingPlatform
import FirebaseCore
import FirebaseAnalytics



@main
struct PixelArtMaker2App: SwiftUI.App {
    init() {
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)

        let _ = Realm.shared
        FirebaseApp.configure()
        GoogleMobileAds.MobileAds.shared.start { status in
            print(status)
            GoogleAdPrompt.promptWithDelay {
                
            }
        }
        
        AppCheckHelper.requestDeviceCheckToken()
        AppCheckHelper.requestDebugToken()
        AppCheckHelper.requestAppAttestToken()

        InAppPurchaseManager().printStatus()
        
        // Create a UMPRequestParameters object.
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = false

    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }}
