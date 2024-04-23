//
//  MenuView.swift
//  PixelArtMaker2
//
//  Created by Changyeol Seo on 4/23/24.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        List {
            NavigationLink {                
                SettingView()
            } label: {
                Text("Setting")
            }

        }
    }
}

#Preview {
    NavigationStack {
        MenuView()
    }
}
