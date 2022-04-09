//
//  NewCanvasView.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/09.
//

import SwiftUI

struct NewCanvasView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var selection = 0
    @State var backgroundColor = Color.white
    @State var isLoadDataOnce = false
    
    var canvasSize:CGSize {
        let w = Consts.canvasSizes[selection]
        let h = Consts.canvasSizes[selection]
        return .init(width: w, height: h)
    }
    
    var body: some View {
        GeometryReader { geomentry in
            
            VStack {
                Canvas { context,size in
                    let w = geomentry.size.width / canvasSize.width
                    let h = geomentry.size.width / canvasSize.height
                    
                    for y in 0..<Int(size.height) {
                        for x in 0..<Int(size.width) {
                            context.fill(.init(roundedRect: .init(x: CGFloat(x) * w + 0.5,
                                                                  y: CGFloat(y) * h + 0.5,
                                                                  width: w - 1.0,
                                                                  height: h - 1.0),
                                               cornerSize: .init(width: 1, height: 1)), with: .color(backgroundColor))

                        }
                    }
                                        
                }
                .frame(width: geomentry.size.width, height: geomentry.size.width, alignment: .center)
                
                HStack {
                    Text("canvas size")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Picker("canvas size", selection: $selection) {
                        ForEach(0..<Consts.canvasSizes.count, id:\.self) { idx in
                            let size = Consts.canvasSizes[idx]
                            Text("\(Int(size))")
                        }
                    }
                    Text("*").foregroundColor(.gray)
                    Picker("canvas size", selection: $selection) {
                        ForEach(0..<Consts.canvasSizes.count, id:\.self) { idx in
                            let size = Consts.canvasSizes[idx]
                            Text("\(Int(size))")
                        }
                    }
                }
                HStack {
                    ColorPicker("", selection: $backgroundColor)
                        .frame(width: 50)
                    SimplePaleteView(color: $backgroundColor, paletteColors: Color.lastSelectColors ?? [])
                    NavigationLink(destination: ColorPresetView()) {
                        Image(systemName: "ellipsis").imageScale(.large)
                    }
                }
                Spacer()
                Button {
                    StageManager.shared.deleteTemp { isSucess in
                        StageManager.shared.initStage(canvasSize:canvasSize)
                        StageManager.shared.stage?.backgroundColor = backgroundColor
                        NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                } label: {
                    OrangeTextView(image: Image(systemName: "rectangle.center.inset.filled"), boldText: nil, text: Text("new canvas confirm button title"))
                }
                
            }
            
            .navigationTitle(Text("new canvas view title"))
            .onAppear {
                if isLoadDataOnce == false {
                    backgroundColor = StageManager.shared.stage?.backgroundColor ?? .white
                    let size = StageManager.shared.canvasSize
                    if let idx = Consts.canvasSizes.firstIndex(of: size.width) {
                        selection = idx
                    }
                    if let idx = Consts.canvasSizes.firstIndex(of: size.height) {
                        selection = idx
                    }
                    isLoadDataOnce = true
                }
            }
        }
        
    }
}

struct NewCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        NewCanvasView()
    }
}
