//
//  LoadView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI

struct LoadView: View {
    @State var stages:[StageModel] = []
    var body: some View {
        List {
            ForEach(0..<stages.count, id:\.self) { idx in
                let stage = stages[idx]
                if let image = stage.previewImage {
                    Image(uiImage: image).resizable().frame(width: 100, height: 100, alignment: .center)
                        .background(stage.backgroundColor)
                }
            }
        }.onAppear {
            StageManager.shared.load { result in
                stages = result
            }
        }.listStyle(PlainListStyle())
    }
}

struct LoadView_Previews: PreviewProvider {
    static var previews: some View {
        LoadView()
    }
}
