//
//  TagView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/27.
//

import SwiftUI

struct TagView: View {
    @State var text:String 
    init(_ text:String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .padding(5)
            .foregroundColor(.k_tagText)
            .background(Color.k_tagBackground)
            .cornerRadius(10)
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView("test")
    }
}
