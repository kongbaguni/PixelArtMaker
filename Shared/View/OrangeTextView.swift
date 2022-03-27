//
//  OrangeTextView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/27.
//

import SwiftUI

struct OrangeTextView: View {
    @State var text:Text
    init(_ text:Text) {
        self.text = text
    }
    var body: some View {
        text
            .font(.system(size: 20, weight: .heavy, design: .rounded))
            .padding(10)
            .foregroundColor(.white)
            .background(.orange)
            .cornerRadius(10)
    }
}

struct OrangeTextView_Previews: PreviewProvider {
    static var previews: some View {
        OrangeTextView(Text("text"))
    }
}
