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
import AppTrackingTransparency
import UserMessagingPlatform


struct ContentView: View {
    init() {
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)

        FirebaseApp.configure()
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "22c15f150946f2ec1887fe3673eff404","028bacd3552b31072f19a617f0c8aef3" ]
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
        
        // Create a UMPRequestParameters object.
        let parameters = UMPRequestParameters()
        // Set tag for under age of consent. Here false means users are not under age.
        parameters.tagForUnderAgeOfConsent = false
        ATTrackingManager.requestTrackingAuthorization { [self] _ in
            ump()
        }
    }
    
    func ump() {
        func loadForm() {
          // Loads a consent form. Must be called on the main thread.
            UMPConsentForm.load { form, loadError in
                if loadError != nil {
                  // Handle the error
                } else {
                    // Present the form. You can also hold on to the reference to present
                    // later.
                    if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.required {
                        form?.present(
                            from: UIApplication.topViewController!,
                            completionHandler: { dismissError in
                                if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.obtained {
                                    // App can start requesting ads.
                                }
                                // Handle dismissal by reloading form.
                                loadForm();
                            })
                    } else {
                        // Keep the form available for changes to user consent.
                    }
                    
                }

            }
        }
        // Create a UMPRequestParameters object.
        let parameters = UMPRequestParameters()
        // Set tag for under age of consent. Here false means users are not under age.
        parameters.tagForUnderAgeOfConsent = false
        #if DEBUG
        let debugSettings = UMPDebugSettings()
//        debugSettings.testDeviceIdentifiers = ["78ce88aff302a5f4dfa5226a766c0b5a"]
        debugSettings.geography = UMPDebugGeography.EEA
        parameters.debugSettings = debugSettings
        #endif
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(
            with: parameters,
            completionHandler: { error in
                if error != nil {
                    // Handle the error.
                    print(error!.localizedDescription)
                } else {
                    let formStatus = UMPConsentInformation.sharedInstance.formStatus
                    if formStatus == UMPFormStatus.available {
                      loadForm()
                    }

                }
            })
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
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//                ATTrackingManager.requestTrackingAuthorization { _ in
//                }
//            }
            
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
