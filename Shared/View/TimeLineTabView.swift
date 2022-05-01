//
//  TimeLineTabView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/05/01.
//

import SwiftUI

struct TimeLineTabView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor(white: 0.5, alpha: 1.0)
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
    }
}

