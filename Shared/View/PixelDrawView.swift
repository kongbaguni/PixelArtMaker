//
//  PixelDrawView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/17.
//

import SwiftUI

fileprivate func getIndex(location:CGPoint)->(Int,Int) {
    let size = UIScreen.screens.first?.bounds.size.width ?? 300
    let w = size / pixelSize.width
    let x = Int(location.x / w)
    let y = Int(location.y / w)
    return (x,y)
}

fileprivate let pixelSize = CGSize(width: 32, height: 32)

struct PixelDrawView: View {
    @State var data:LayerModel = LayerModel(size: pixelSize) {
        didSet {
            StageManager.shared.stage.change(layer: data)
        }
    }
    @State var selectedColor:Color = .black
    
    var body: some View {
        Canvas { context, size in
            let w = size.width / CGFloat(data.colors.first?.count ?? 1)
            for (y,list) in data.colors.enumerated() {
                for (x,color) in list.enumerated() {
                    context.stroke(
                        Path(ellipseIn: CGRect(origin: .init(x: CGFloat(x) * w, y: CGFloat(y) * w),
                                               size: .init(width: 10, height: 10))),
                        with: .color(color),
                        lineWidth: 4)
                        
                }
            }
        }.gesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local).onChanged({ value in
            print(value.location)
            let idx = getIndex(location: value.location)
            if idx.0 < data.colors.count && idx.0 > 0 {
                if idx.1 < data.colors[idx.0].count && idx.1 > 0 {
                    data.colors[idx.1][idx.0] = selectedColor
                }
            }
        }))
        .background(.gray)
        .onAppear {
            data = StageManager.shared.stage.selectedLayer
        }
    }
}

struct PixelDrawView_Previews: PreviewProvider {
    static var previews: some View {
        PixelDrawView()
    }
}
