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
        ConsentForm.load { form, loadError in
            if loadError != nil {
              // Handle the error
            } else {
                // Present the form. You can also hold on to the reference to present
                // later.
                if ConsentInformation.shared.consentStatus == ConsentStatus.required {
                    form?.present(
                        from: UIApplication.shared.lastViewController!,
                        completionHandler: { dismissError in
                            if ConsentInformation.shared.consentStatus == ConsentStatus.obtained {
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
    ConsentInformation.shared.reset()
    #endif

    // Create a UMPRequestParameters object.
    let parameters = RequestParameters()
    // Set tag for under age of consent. Here false means users are not under age.
    parameters.isTaggedForUnderAgeOfConsent = false
    #if DEBUG
    let debugSettings = DebugSettings()
//        debugSettings.testDeviceIdentifiers = ["78ce88aff302a5f4dfa5226a766c0b5a"]
    debugSettings.geography = DebugGeography.EEA
    parameters.debugSettings = debugSettings
    #endif
    ConsentInformation.shared.requestConsentInfoUpdate(
        with: parameters,
        completionHandler: { error in
            if error != nil {
                // Handle the error.
                print(error!.localizedDescription)
            } else {
                let formStatus = ConsentInformation.shared.formStatus
                if formStatus == FormStatus.available {
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

