//
//  AppCheck.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/21.
//

import Foundation
import FirebaseCore
import FirebaseAppCheck

struct AppCheck {
    static func requestDeviceCheckToken() {
      guard let firebaseApp = FirebaseApp.app() else {
        return
      }

      DeviceCheckProvider(app: firebaseApp)?.getToken { token, error in
        if let token = token {
          print("DeviceCheck token: \(token.token), expiration date: \(token.expirationDate)")
        }

        if let error = error {
          print("DeviceCheck error: \((error as NSError).userInfo)")
        }
      }
    }

    static func requestDebugToken() {
      guard let firebaseApp = FirebaseApp.app() else {
        return
      }

      if let debugProvider = AppCheckDebugProvider(app: firebaseApp) {
        print("Debug token: \(debugProvider.currentDebugToken())")

        debugProvider.getToken { token, error in
          if let token = token {
            print("Debug FAC token: \(token.token), expiration date: \(token.expirationDate)")
          }

          if let error = error {
            print("Debug error: \(error)")
          }
        }
      }
    }

    @available(iOS 14.0, *)
    static func requestAppAttestToken() {
      guard let firebaseApp = FirebaseApp.app() else {
        return
      }

      guard let appAttestProvider = AppAttestProvider(app: firebaseApp) else {
        print("Failed to instantiate AppAttestProvider")
        return
      }

      appAttestProvider.getToken { token, error in
        if let token = token {
          print("App Attest FAC token: \(token.token), expiration date: \(token.expirationDate)")
        }

        if let error = error {
          print("App Attest error: \(error)")
        }
      }
    }
}
