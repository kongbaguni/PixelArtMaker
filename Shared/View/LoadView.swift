//
//  LoadView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI
import SDWebImageSwiftUI

//import RealmSwift


struct LoadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var stages:[MyStageModel.ThreadSafeModel] = []

    @State var loadingStart = false
    @State var sortIndex = 0
    
    private var pickerView : some View {
        Picker(selection:$sortIndex, label:Text("sort")) {
            ForEach(0..<Sort.SortTypeForMyGellery.count, id:\.self) { idx in
                let type = Sort.SortTypeForMyGellery[idx]
                Sort.getText(type: type)
            }
        }.onChange(of: sortIndex) { newValue in
            withAnimation(.easeInOut) {
                load(animate: true)
            }
        }
    }
    
    private func getWidth(width:CGFloat,number:Int)->CGFloat {
        switch number {
        case 0:
            return 0
        case 1:
            return width - 10
        default:
            return (width - 40) / CGFloat(number)
        }
    }
    
    private func makeListView(gridItems:[GridItem], width:CGFloat) -> some View {
        
        LazyVGrid(columns: gridItems, spacing:20) {
            ForEach(stages, id: \.self) {stage in
                Button {
                    if loadingStart == false {
                        loadingStart = true
                        stages = [stage]
                        StageManager.shared.openStage(id: stage.documentId) { (result,errorA) in
                            StageManager.shared.saveTemp { errorB in
                                if errorA == nil && errorB == nil {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                                isShowToast = errorA != nil || errorB != nil
                                toastMessage = errorA?.localizedDescription ?? errorB?.localizedDescription ?? ""
                            }
                        }
                    }
                } label : {
                    VStack {
                        WebImage(url: stage.imageURL)
                            .placeholder(.imagePlaceHolder.resizable())
                            .resizable().frame(width: loadingStart && stages.count == 1 ? getWidth(width: width, number: 1)
                                               : getWidth(width: width, number: gridItems.count),
                                               height: loadingStart  && stages.count == 1  ? getWidth(width: width, number: 1) : getWidth(width: width, number: gridItems.count),
                                               alignment: .center)
                        HStack {
                            Text("id").font(.system(size: 10))
                            Text(stage.documentId)
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        HStack {
                            Text("update").font(.system(size:10))
                            Text(stage.updateDt.formatted(date:.long, time: .standard))
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Spacer()
                        }

                        Spacer()
                    }.frame(width: loadingStart && stages.count == 1 ? getWidth(width: width, number: 1) : getWidth(width: width, number: gridItems.count),
                            height: loadingStart && stages.count == 1 ? getWidth(width: width, number: 1) + 30 : getWidth(width: width, number: gridItems.count) + 30 ,
                            alignment: .center)
                }
                
            }
        }
        .opacity(loadingStart ? 0.5 : 1.0)
        .padding(.horizontal)
//        .animation(.easeInOut, value: loadingStart)

    }
    
    private func load(animate:Bool = false) {
        if animate {
            loadingStart = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                loadingStart = false
            }
        }
        switch Sort.SortType.allCases[sortIndex] {
        case .latestOrder:
            stages = StageManager.shared.stagePreviews.sorted(byKeyPath: "updateDt", ascending: true).reversed().map({ model in
                return model.threadSafeModel
            })
        case .oldnet:
            stages = StageManager.shared.stagePreviews.sorted(byKeyPath: "updateDt", ascending: false).reversed().map({ model in
                return model.threadSafeModel
            })
        default:
            stages = []
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
            ZStack {
                ScrollView {
                    pickerView
                    makeListView(gridItems:
                                    loadingStart && stages.count == 1 ? [.init(.fixed(geomentry.size.width))]
                                 : geomentry.size.width < geomentry.size.height
                                 ? Utill.makeGridItems(length: 2, screenWidth: geomentry.size.width, padding:20)
                                 : Utill.makeGridItems(length: 4, screenWidth: geomentry.size.width, padding:20)
                                 ,width:geomentry.size.width
                    )
                }
                
                if stages.count == 0 {
                    Text(loadingStart ? "open start" : "empty gallery title").padding(20)
                }
                VStack {
                    if loadingStart {
                        ActivityIndicator(isAnimating: $loadingStart, style: .large)
                        if stages.count == 1 {
                            Text("open start").padding(20)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text("my gellery"))
        .onAppear {
            load()
            loadingStart = true
            StageManager.shared.loadList { sucess in
                load()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {[self] in
                    loadingStart = false
                }
            }
            
        }
    }
    
    
   
}

struct LoadView_Previews: PreviewProvider {
    static var previews: some View {
        LoadView()
    }
}
