//
//  HomeView.swift
//  PixelArtMaker2
//
//  Created by Changyeol Seo on 4/23/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("app title")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    MenuView()
                } label: {
                    Image(systemName: "line.3.horizontal")
                }

            }
        }
        .navigationTitle(.init("app title"))
    }
}

#Preview {
    HomeView()
}
