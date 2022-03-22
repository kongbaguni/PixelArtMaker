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
                VStack {
                    Canvas { context, size in
                        for data in stage.totalColors {
                            let w = size.width / CGFloat(data.first?.count ?? 1)
                            for (y,list) in data.enumerated() {
                                for (x,color) in list.enumerated() {
                                    if color != .clear {
                                        context.fill(.init(roundedRect: .init(x: CGFloat(x) * w - 0.01,
                                                                              y: CGFloat(y) * w - 0.01,
                                                                              width: w + 0.02,
                                                                              height: w + 0.02),
                                                           cornerSize: .zero), with: .color(color))
                                    }
                                }
                            }
                        }
                    }
                    .background(stage.backgroundColor)
                    .border(Color.white)
                    .frame(width: 200, height: 200, alignment: .center)
                }
                Text(stages[idx].title ?? "").foregroundColor(.white)
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
