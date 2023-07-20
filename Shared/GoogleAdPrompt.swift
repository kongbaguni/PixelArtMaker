//
//  UserMessagePrompt.swift
//  GaweeBaweeBoh
//
//  Created by Changyeol Seo on 2023/07/20.
//

import Foundation
import UIKit
import UserMessagingPlatform
import AppTrackingTransparency
fileprivate func requestTrackingAuthorization(complete:@escaping()->Void) {
    ATTrackingManager.requestTrackingAuthorization { status in
        print("google ad tracking status : \(status)")
    }
}

fileprivate func userMessagePlatformPrompt(complete:@escaping()->Void) {
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
                        from: UIApplication.shared.lastViewController!,
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
    
    #if DEBUG
    UMPConsentInformation.sharedInstance.reset()
    #endif

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
            complete()
        })
}
/** 구글 AD 사용 위한 권한 등 프롬프트 요청..*/
struct GoogleAdPrompt {
    static func promptWithDelay(complete:@escaping()->Void) {
        // contentView.init 등에서 호출할 때 1초 딜레이를 주어야 알람창이 뜬다.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            requestTrackingAuthorization {
                userMessagePlatformPrompt {
                    complete()
                }
            }
        }
    }
}

