//
//  ContentView.swift
//  Shared
//
//  Created by Changyeol Seo on 2022/02/17.
//

import SwiftUI
import Firebase
import GoogleMobileAds
import SwiftyStoreKit
import RealmSwift
import FirebaseCore
import FirebaseAppCheck

struct ContentView: View {
    init() {
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)

        FirebaseApp.configure()
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "22c15f150946f2ec1887fe3673eff404","028bacd3552b31072f19a617f0c8aef3" ]
        // Sample device ID
        GADMobileAds.sharedInstance().start { status in
            print("-------------------------------")
            print("google ad status : \(status.adapterStatusesByClassName)")
        }

        AppCheckHelper.requestDeviceCheckToken()

        AppCheckHelper.requestDebugToken()

        if #available(iOS 14.0, *) {
            AppCheckHelper.requestAppAttestToken()
        }

        InAppPurchaseManager().printStatus()
    }
    
    var body: some View {
        GeometryReader { geomentry in
            NavigationView {
                PixelDrawView()
                    .navigationTitle(
                        .app_title
                    )
                    .background(Color.k_background)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .frame(width: geomentry.size.width, height: geomentry.size.height, alignment: .center)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            //Portrait 고정
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            AppDelegate.orientationLock = .portrait
            
            SwiftyStoreKit.completeTransactions { purchases in
                for purchase in purchases {
                    print(purchase)
                    switch purchase.transaction.transactionState {
                    case .purchased, .restored:
                        if purchase.needsFinishTransaction {
                            // Deliver content from server, then:
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                        // Unlock content
                    case .failed, .purchasing, .deferred:
                        break // do nothing
                    default:
                        break
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
