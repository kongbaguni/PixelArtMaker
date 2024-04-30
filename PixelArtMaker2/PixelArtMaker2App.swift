//
//  PixelArtMaker2App.swift
//  PixelArtMaker2
//
//  Created by Changyeol Seo on 4/23/24.
//

import SwiftUI
import RealmSwift
import FirebaseCore
import GoogleMobileAds
import SwiftyStoreKit
import FirebaseAppCheck
import AppTrackingTransparency
import UserMessagingPlatform


@main
struct PixelArtMaker2App: SwiftUI.App {
    init() {
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)

        let _ = Realm.shared
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start { status in
            print(status)
            GoogleAdPrompt.promptWithDelay {
                
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }}
