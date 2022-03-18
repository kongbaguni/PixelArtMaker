//
//  ContentView.swift
//  Shared
//
//  Created by Changyeol Seo on 2022/02/17.
//

import SwiftUI
#if !MAC
import Firebase
#endif

struct ContentView: View {
    init() {
        #if !MAC
        FirebaseApp.configure()
        #endif
    }
    
    var body: some View {
        NavigationView {            
            PixelDrawView()
                .navigationTitle(.app_title)
                .background(Color.k_background)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
