//
//  TimeLineTabView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/05/01.
//

import SwiftUI

struct TimeLineTabView: View {
    init() {
        UITabBar.appearance().backgroundColor = .black
    }
    var body: some View {
        TabView {
            TimeLineView().tabItem {
                Image(systemName: "text.below.photo")
            }
            TimeLineReplyView().tabItem {
                Image(systemName: "text.bubble")
            }
        }
        .background(Color.k_background)
        .tabViewStyle(PageTabViewStyle())
        
    }
}

