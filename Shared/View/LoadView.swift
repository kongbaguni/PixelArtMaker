//
//  LoadView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI

struct LoadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var stages:[StageModel] = []
    var body: some View {
        List {
            ForEach(0..<stages.count, id:\.self) { idx in
                let stage = stages[idx]
                Button {
                    StageManager.shared.stage = stage
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    if let image = stage.previewImage {
                        Image(uiImage: image).resizable().frame(width: 200, height: 200, alignment: .center)
                            .background(stage.backgroundColor)
                    }
                    else {
                        Image(uiImage:#imageLiteral(resourceName: "paint"))
                    }
                }

            }
        }.onAppear {
            StageManager.shared.load { result in
                stages = result
            }
        }.listStyle(InsetListStyle())
    }
}

struct LoadView_Previews: PreviewProvider {
    static var previews: some View {
        LoadView()
    }
}
