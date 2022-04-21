//
//  AppCheck.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/21.
//

import Foundation
import FirebaseCore
import FirebaseAppCheck

struct AppCheckHelper {
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
    
    
    static func check() {        
        AppCheck.appCheck().token(forcingRefresh: false) { token, error in
            guard error == nil else {
                // Handle any errors if the token was not retrieved.
                print("Unable to retrieve App Check token: \(error!)")
                return
            }
            guard let token = token else {
                print("Unable to retrieve App Check token.")
                return
            }

            // Get the raw App Check token string.
            let tokenString = token.token

            // Include the App Check token with requests to your server.
            let url = URL(string: "https://yourbackend.example.com/yourApiEndpoint")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(tokenString, forHTTPHeaderField: "X-Firebase-AppCheck")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle response from your backend.
            }
            task.resume()
        }
    }
}
