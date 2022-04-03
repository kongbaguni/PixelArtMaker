//
//  LoadView.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import SwiftUI
import RealmSwift

fileprivate let width1 = screenBounds.width / 2 - 10
fileprivate let width2 = screenBounds.width - 10

fileprivate let height1 = width1 + 50
fileprivate let height2 = width2 + 50

struct LoadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isShowToast = false
    @State var toastMessage = ""
    @State var stages:[MyStageModel] = []
    @State var gridItems:[GridItem] = [
        .init(.fixed(width1)),
        .init(.fixed(width1))
    ]
    @State var loadingStart = false
    @State var sortIndex = 0
    
    var body: some View {
            
        ScrollView {
            Picker(selection:$sortIndex, label:Text("sort")) {
                ForEach(0..<Sort.SortTypeForMyGellery.count, id:\.self) { idx in
                    let type = Sort.SortTypeForMyGellery[idx]
                    Sort.getText(type: type)
                }
            }.onChange(of: sortIndex) { newValue in
                load()
            }

            if stages.count == 0 {
                Text("empty gallery title").padding(20)
            }
            if loadingStart {
                Text("open start").padding(20)
            }
            LazyVGrid(columns: gridItems, spacing:20) {
                ForEach(stages, id: \.self) {stage in
                    Button {
                        if loadingStart == false {
                            loadingStart = true
                            stages = [stage]
                            gridItems = [.init(.fixed(width2))]
                            StageManager.shared.openStage(id: stage.documentId) { (result,errorA) in
                                StageManager.shared.saveTemp { errorB in
                                    if errorA == nil && errorB == nil {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                    isShowToast = errorA != nil || errorB != nil
                                    toastMessage = errorA?.localizedDescription ?? errorB?.localizedDescription ?? ""
                                }                                
                            }
                        }
                    } label : {
                        VStack {
                            ZStack {
                                Image(uiImage: stage.image).resizable().frame(width: loadingStart ? width2 : width1,
                                                                              height: loadingStart ? width2 : width1,
                                                                              alignment: .center)
                                .opacity(loadingStart ? 0.2 : 1.0)
                                ActivityIndicator(isAnimating: $loadingStart, style: .large)
                                    .frame(width: loadingStart ? width2 : width1,
                                           height: loadingStart ? width2 : width1, alignment: .center)
                            }
                            Text(stage.documentId)
                                .font(SwiftUI.Font.system(size: loadingStart ? 16 : 8))
                                .padding(5)
                                .foregroundColor(.k_tagText)
                                .background(Color.k_tagBackground)
                                .cornerRadius(10)
                            Text(stage.updateDt.formatted(date:.long, time: .standard))
                                .font(SwiftUI.Font.system(size: loadingStart ? 16 : 8))
                                .padding(5)
                                .foregroundColor(.k_tagText)
                                .background(Color.k_tagBackground)
                                .cornerRadius(10)
                            
                        }.frame(width: loadingStart ? width2 + 10 : width1,
                                height: loadingStart ? height2 + 10 : height1,
                                alignment: .center)
                    }

                }
            }
            .padding(.horizontal)            
        }
        .navigationBarTitle(Text("my gellery"))
        .onAppear {
            load()
            StageManager.shared.loadList { sucess in
                load()
            }
        }
    }
    func load() {
        switch Sort.SortType.allCases[sortIndex] {
        case .latestOrder:
            stages = StageManager.shared.stagePreviews.sorted(byKeyPath: "updateDt", ascending: true).reversed()
        case .oldnet:
            stages = StageManager.shared.stagePreviews.sorted(byKeyPath: "updateDt", ascending: false).reversed()
        default:
            stages = []
        }
        
        gridItems = stages.count > 1 ? [.init(.fixed(width1)),.init(.fixed(width1))] : [.init(.fixed(width2))]
        
    }
}

struct LoadView_Previews: PreviewProvider {
    static var previews: some View {
        LoadView()
    }
}
