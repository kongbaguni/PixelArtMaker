//
//  TimeLineTabView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/05/01.
//

import SwiftUI

struct TimeLineTabView: View {
    @State var selection = 0
    var body: some View {
        TabView(selection: $selection) {
            TimeLineReplyView()
                .tabItem { Image(systemName: "text.bubble") }
                .tag(0)
            TimeLineView()
                .tabItem { Image(systemName: "text.below.photo") }
                .tag(1)
        }
  
    }
}

