//
//  SidebarMenuView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/08.
//

import SwiftUI

struct SidebarMenuView: View {
    let image:Image
    let text:Text
    var body: some View {
        HStack {
            image
                .foregroundColor(.K_boldText)
                .imageScale(.large)
            text
                .foregroundColor(.gray)
                .font(.headline)
        }
    }
}

struct SidebarMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarMenuView(image: Image(systemName: "gear"), text: Text("test"))
    }
}
