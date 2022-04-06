//
//  LoadView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI
import SDWebImageSwiftUI

//import RealmSwift

fileprivate let width1 = screenBounds.width - 10
fileprivate let width2 = screenBounds.width / 2 - 10

fileprivate let height1 = width1 + 50
fileprivate let height2 = width2 + 50

struct LoadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var stages:[MyStageModel.ThreadSafeModel] = []
    @State var gridItems:[GridItem] = [
        .init(.fixed(width2)),
        .init(.fixed(width2))
    ]
    @State var loadingStart = false
    @State var sortIndex = 0
    
    var body: some View {
        ZStack {
            ScrollView {
                Picker(selection:$sortIndex, label:Text("sort")) {
                    ForEach(0..<Sort.SortTypeForMyGellery.count, id:\.self) { idx in
                        let type = Sort.SortTypeForMyGellery[idx]
                        Sort.getText(type: type)
                    }
                }.onChange(of: sortIndex) { newValue in
                    load(animate: true)
                }
                
                
                LazyVGrid(columns: gridItems, spacing:20) {
                    ForEach(stages, id: \.self) {stage in
                        Button {
                            if loadingStart == false {
                                loadingStart = true
                                stages = [stage]
                                gridItems = [.init(.fixed(width1))]
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
                                    .placeholder(.imagePlaceHolder)
                                    .resizable().frame(width: loadingStart && stages.count == 1 ? width1 : width2,
                                                                              height: loadingStart  && stages.count == 1  ? width1 : width2,
                                                                              alignment: .center)
                                TagView(Text(stage.documentId))
                                TagView(Text(stage.updateDt.formatted(date:.long, time: .standard)))
                                Spacer()
                            }.frame(width: loadingStart && stages.count == 1 ? width1 + 10 : width2,
                                    height: loadingStart && stages.count == 1 ? height1 + 10 : height2,
                                    alignment: .center)
                        }
                        
                    }
                }
                .opacity(loadingStart ? 0.5 : 1.0)
                .padding(.horizontal)
                .animation(.easeInOut, value: loadingStart)
            }
            if stages.count == 0 {
                Text("empty gallery title").padding(20)
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
    
    
    func load(animate:Bool = false) {
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
        
        gridItems = stages.count > 1 ? [.init(.fixed(width2)),.init(.fixed(width2))] : [.init(.fixed(width1))]
        
    }
}

struct LoadView_Previews: PreviewProvider {
    static var previews: some View {
        LoadView()
    }
}
