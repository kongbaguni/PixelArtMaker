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
    
    @State var isToast = false
    @State var toastMessage = ""
    @State var image:Image? = nil
    
    var canvasSize:CGSize {
        let w = Consts.canvasSizes[selection]
        let h = Consts.canvasSizes[selection]
        return .init(width: w, height: h)
    }
    
    private func makeCanvasView(width:CGFloat)-> some View {
        Group {
            if let img = image {
                img.resizable()
            } else {
                Image.imagePlaceHolder.resizable()
            }
        }
        .frame(width: width, height: width, alignment: .center)
    }
    
    
    private func makeInfomationView()-> some View {
        Group {
            HStack {
                Text("canvas size")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Picker("canvas size", selection: $selection) {
                    ForEach(0..<Consts.canvasSizes.count, id:\.self) { idx in
                        let size = Consts.canvasSizes[idx]
                        Text("\(Int(size))")
                    }
                }.onChange(of: selection) { newValue in
                    updateImage()
                }
                Text("*").foregroundColor(.gray)
                Picker("canvas size", selection: $selection) {
                    ForEach(0..<Consts.canvasSizes.count, id:\.self) { idx in
                        let size = Consts.canvasSizes[idx]
                        Text("\(Int(size))")
                    }
                }.onChange(of: selection) { newValue in
                    updateImage()
                }
            }
            HStack {
                ColorPicker("", selection: $backgroundColor)
                    .frame(width: 50)
                    .onChange(of: backgroundColor) { newColor in
                        updateImage()
                    }
                
                SimplePaleteView(color: $backgroundColor, paletteColors: Color.lastSelectColors ?? [])
                NavigationLink(destination: ColorPresetView()) {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private func makeButton() -> some View {
        Button {
            var clearErr:Error? = nil
            if AuthManager.shared.isSignined == false {
                clearErr = HistoryManager.shared.clear()
                StageManager.shared.initStage(canvasSize:canvasSize)
                StageManager.shared.stage?.backgroundColor = backgroundColor
                NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
                presentationMode.wrappedValue.dismiss()

            } else {
                StageManager.shared.deleteTemp { errorA in
                    clearErr = HistoryManager.shared.clear()
                    StageManager.shared.initStage(canvasSize:canvasSize)
                    StageManager.shared.stage?.backgroundColor = backgroundColor
                    NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
                    
                    
                    StageManager.shared.saveTemp { errorB in
                        presentationMode.wrappedValue.dismiss()
                        isToast = (clearErr ?? errorA ?? errorB) != nil
                        toastMessage = (clearErr ?? errorA ?? errorB)?.localizedDescription ?? ""
                    }                    
                }
            }
            
        } label: {
            OrangeTextView(image: Image(systemName: "rectangle.center.inset.filled"), boldText: nil, text: Text("new canvas confirm button title"))
        }
    }
    
    func updateImage() {
        DispatchQueue.global().async {
            if let image = Image(pixelSize: (width: Int(canvasSize.width), height: Int(canvasSize.height)),
                                 backgroundColor: backgroundColor, size: CGSize(width: 800, height: 800)) {
                self.image = image
            } else {
                abort()
            }
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
            if geomentry.size.width < geomentry.size.height {
                ScrollView {
                    makeCanvasView(width: geomentry.size.width)
                    
                    makeInfomationView()
                    if InAppPurchaseModel.isSubscribe == false {
                        VStack {
                            NativeAdView()
                                .padding(.top,20)
                                .padding(.bottom,10)
                        }
                    } else {
                        Spacer()
                            .frame(height:50)
                    }
                    makeButton()
                        .padding(.bottom,10)
                }
            }
            else {
                HStack {
                    makeCanvasView(width: geomentry.size.height)
                    Spacer()
                    ScrollView {
                        makeInfomationView()
                        VStack {
                            NativeAdView()
                                .padding(.top,20)
                                .padding(.bottom,10)
                        }
                        makeButton()
                            .padding(.bottom,10)
                    }
                }
            }
        }
        .toast(message: toastMessage, isShowing: $isToast, duration: 4)
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
            updateImage()
        }
        
    }
}

struct NewCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        NewCanvasView()
    }
}
