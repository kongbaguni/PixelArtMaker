//
//  OrangeTextView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/27.
//

import SwiftUI

struct OrangeTextView: View {
    let image:Image?
    let boldText:Text?
    let text:Text
    let textSize:CGFloat
    init(_ text:Text) {
        image = nil
        boldText = nil
        self.text = text
        textSize = 20
    }
    
    init(image:Image?, boldText:Text? = nil, text:Text, textSize:CGFloat = 20) {
        self.image = image
        self.boldText = boldText
        self.text = text
        self.textSize = textSize
    }
    
    var body: some View {
        HStack {
            if let img = image {
                img
            }
            if let txt = boldText {
                txt.font(.system(size:textSize , weight: .heavy, design: .serif))
            }
            text.font(.system(size: textSize, weight: .regular, design: .serif))
        }
        .padding(10)
        .foregroundColor(.white)
        .background(.orange)
        .cornerRadius(10)
    }
}

struct OrangeTextView_Previews: PreviewProvider {
    static var previews: some View {
        OrangeTextView(image: nil, boldText: nil, text: Text("test"), textSize: 20)
    }
}
