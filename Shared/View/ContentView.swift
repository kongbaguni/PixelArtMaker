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
        GADMobileAds.sharedInstance().start { status in
            print("-------------------------------")
            print("google ad status : \(status.adapterStatusesByClassName)")
            GoogleAd.shared.loadAd { isSucess in
                
            }
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
