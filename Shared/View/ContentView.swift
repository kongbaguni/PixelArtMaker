//
//  ContentView.swift
//  Shared
//
//  Created by Changyeol Seo on 2022/02/17.
//

import SwiftUI
import Firebase
import GoogleMobileAds

struct ContentView: View {
    init() {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "22c15f150946f2ec1887fe3673eff404","028bacd3552b31072f19a617f0c8aef3" ]
        // Sample device ID
        GADMobileAds.sharedInstance().start { status in
            print("-------------------------------")
            print("google ad status : \(status.adapterStatusesByClassName)")
        }
        
    }
    
    var body: some View {
        NavigationView {
            PixelDrawView()
                .navigationTitle(
                    .app_title
                )
                .background(Color.k_background)
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
