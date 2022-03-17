//
//  SaveView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI

struct SaveView: View {
    @State var colors:[[[Color]]] = []
    @State var backgroundColor:Color = .white
    
    var body: some View {
        VStack {
            Canvas { context, size in
                for data in colors {
                    let w = size.width / CGFloat(data.first?.count ?? 1)
                    for (y,list) in data.enumerated() {
                        for (x,color) in list.enumerated() {
                            if color != .clear {
                                context.fill(.init(roundedRect: .init(x: CGFloat(x) * w ,
                                                                      y: CGFloat(y) * w ,
                                                                      width: w ,
                                                                      height: w ),
                                                   cornerSize: .zero), with: .color(color))
                            }
                        }
                    }
                }
            }
            .background(backgroundColor)
            .frame(width: 100, height: 100, alignment: .center)
        }
        .onAppear {
            if let stage = StageManager.shared.stage {
                self.colors = stage.layers.map({ model in
                    return model.colors
                })
                backgroundColor = stage.backgroundColor
            }
        }
    }
}

struct SaveView_Previews: PreviewProvider {
    static var previews: some View {
        SaveView()
    }
}
