//
//  LabelTextView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/02.
//

import SwiftUI

struct LabelTextView: View {
    @State var label:String
    @State var text:String
    init(label:String,text:String) {
        self.label = label
        self.text = text
    }
    var body: some View {
        HStack {
            Text(label)
                .font(Font.system(size: 10, weight: .bold, design: .serif))
                .foregroundColor(.white)
            
            Text(text)
                .font(.system(size: 10, weight: .regular, design: .serif))
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(5)
        .background(Color.gray)
    }
}

struct LabelTextView_Previews: PreviewProvider {
    static var previews: some View {
        LabelTextView(label: "test", text: "안녕하쇼")
    }
}
