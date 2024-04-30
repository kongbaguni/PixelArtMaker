//
//  ContentView.swift
//  PixelArtMaker2
//
//  Created by Changyeol Seo on 4/23/24.
//

import SwiftUI
import SwiftyStoreKit

struct ContentView: View {
    var body: some View {
        NavigationStack {
            PixelDrawView()
                .navigationTitle("app title")
                .navigationBarTitleDisplayMode(.inline)
        }
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

#Preview {
    ContentView()
}
