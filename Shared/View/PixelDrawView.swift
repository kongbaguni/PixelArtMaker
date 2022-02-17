//
//  PixelDrawView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyeol Seo on 2022/02/17.
//

import SwiftUI

fileprivate func getIndex(location:CGPoint)->(Int,Int) {
    let x = Int(location.x / 14)
    let y = Int(location.y / 14)
    return (x,y)
}

struct PixelDrawView: View {
    @State var data:PixelModel = PixelModel(size: .init(width: 32, height: 32))
    @State var selectedColor:Color = .black
    
    var body: some View {
        Canvas { context, size in
            for (y,list) in data.colors.enumerated() {
                for (x,color) in list.enumerated() {
                    context.stroke(
                        Path(ellipseIn: CGRect(origin: .init(x: x * 14 + 4, y: y * 14 + 4),
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
        
    }
}

struct PixelDrawView_Previews: PreviewProvider {
    static var previews: some View {
        PixelDrawView()
    }
}
